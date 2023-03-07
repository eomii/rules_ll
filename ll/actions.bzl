"""# `//ll:actions.bzl`

Actions wiring up inputs, outputs, and tools to emit output files.

Every function in this file effectively wraps `ctx.actions.run` or
`ctx.actions.run_shell`.
"""

load(
    "//ll:args.bzl",
    "compile_object_args",
    "create_archive_library_args",
    "link_executable_args",
)
load(
    "//ll:driver.bzl",
    "compiler_driver",
)
load(
    "//ll:environment.bzl",
    "compile_object_environment",
)
load(
    "//ll:inputs.bzl",
    "compilable_sources",
    "compile_object_inputs",
    "create_archive_library_inputs",
    "link_executable_inputs",
    "link_shared_object_inputs",
)
load(
    "//ll:outputs.bzl",
    "compile_object_outputs",
    "create_archive_library_outputs",
    "link_executable_outputs",
    "link_shared_object_outputs",
    "precompile_interface_outputs",
)
load(
    "//ll:tools.bzl",
    "compile_object_tools",
    "linking_tools",
)

def compile_objects(
        ctx,
        headers,
        defines,
        includes,
        angled_includes,
        bmis,
        internal_bmis):
    """Create compiled objects emitted by the rule.

    Args:
        ctx: The rule context.
        headers: A `depset` of files made available to compile actions.
        defines: A `depset` of defines passed to compile actions.
        includes: A `depset` of includes passed to compile actions.
        angled_includes: A `depset` of angled includes passed to compile actions.
        bmis: A `depset` of tuples `(interface, name)`, each consisting of a
            binary module interface `interface` and a module name `name`.
        internal_bmis: Like `bmis`, but can't see the files in `bmis` during
            compilation.

    Returns:
        A tuple `(out_files, cdfs)`, of output files and compilation database
        fragments.
    """
    internal_bmi_files = [bmi for bmi, _ in internal_bmis]
    out_files = []
    cdfs = []

    for in_file in internal_bmi_files:
        file_out, cdf_out = compile_object(
            ctx,
            in_file,
            headers,
            defines,
            includes,
            angled_includes,
            bmis,
        )
        out_files.append(file_out)
        cdfs.append(cdf_out)

    for in_file in compilable_sources(ctx):
        file_out, cdf_out = compile_object(
            ctx,
            in_file,
            headers,
            defines,
            includes,
            angled_includes,
            depset(internal_bmis, transitive = [bmis]),
        )
        out_files.append(file_out)
        cdfs.append(cdf_out)

    return out_files, cdfs

def compile_object(
        ctx,
        in_file,
        headers,
        defines,
        includes,
        angled_includes,
        bmis):
    """Create a compiled object.

    Args:
        ctx: The rule context.
        in_file: The input file to compile.
        headers: A `depset` of files made available to the compile action.
        defines: A `depset` of defines passed to the compile action.
        includes: A `depset` of includes passed to the compile action.
        angled_includes: A `depset` of angled includes passed to the compile
            action.
        bmis: A `depset` of tuples `(interface, name)`, each consisting of a
            binary module interface `interface` and a module name `name`.

    Returns:
        A tuple `(out_file, cdf)`, of an output file and a compilation database
        fragment.
    """

    file_out, cdf_out = compile_object_outputs(ctx, in_file)

    ctx.actions.run(
        outputs = [file_out, cdf_out],
        inputs = compile_object_inputs(
            ctx,
            in_file,
            headers,
            bmis,
        ),
        executable = compiler_driver(ctx, in_file),
        tools = compile_object_tools(ctx),
        arguments = compile_object_args(
            ctx,
            in_file,
            file_out,
            cdf_out,
            defines,
            includes,
            angled_includes,
            bmis,
        ),
        mnemonic = "LlCompileObject",
        use_default_shell_env = False,
        env = compile_object_environment(ctx),
    )
    return file_out, cdf_out

def precompile_interfaces(
        ctx,
        headers,
        defines,
        includes,
        angled_includes,
        bmis,
        precompile_exposed):
    """Create precompiled module interfaces.

    Args:
        ctx: The rule context.
        headers: A `depset` of files made available to compile actions.
        defines: A `depset` of defines passed to compile actions.
        includes: A `depset` of includes passed to compile actions.
        angled_includes: A `depset` of angled includes passed to compile actions.
        bmis: A `depset` of tuples `(interface, name)`, each consisting of a
            binary module interface `interface` and a module name `name`.
        precompile_exposed: A `boolean` indicating whether to precompile exposed
            BMIs. Set to `True` for libraries and to `False` for binaries.

    Returns:
        A tuple `(internal_bmis, exposed_bmis, cdfs)`.
    """
    cdfs = []

    # Internal BMIs. Not exposed to downstream targets.
    internal_bmis = []
    for in_file, module_name in ctx.attr.interfaces.items():
        file_out, cdf_out = precompile_interface(
            ctx,
            in_file.files.to_list()[0],
            headers,
            defines,
            includes,
            angled_includes,
            bmis,
        )
        internal_bmis.append((file_out, module_name))
        cdfs.append(cdf_out)

    # Exposed BMIs are available to direct dependents of the target. Internal
    # BMIs are available to the precompilation steps for these interfaces.
    exposed_bmis = []
    if precompile_exposed:
        for in_file, module_name in ctx.attr.exposed_interfaces.items():
            file_out, cdf_out = precompile_interface(
                ctx,
                in_file.files.to_list()[0],
                headers,
                defines,
                includes,
                angled_includes,
                depset(
                    internal_bmis,
                    transitive = [bmis],
                ),
            )
            exposed_bmis.append((file_out, module_name))
            cdfs.append(cdf_out)

    return internal_bmis, exposed_bmis, cdfs

def precompile_interface(
        ctx,
        in_file,
        headers,
        defines,
        includes,
        angled_includes,
        bmis):
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    file_out, cdf_out = precompile_interface_outputs(ctx, in_file)

    ctx.actions.run(
        outputs = [file_out, cdf_out],
        inputs = compile_object_inputs(
            ctx,
            in_file,
            headers,
            bmis,
        ),
        executable = toolchain.cpp_driver,
        tools = compile_object_tools(ctx),
        arguments = compile_object_args(
            ctx,
            in_file,
            file_out,
            cdf_out,
            defines,
            includes,
            angled_includes,
            bmis,
        ),
        mnemonic = "LlPrecomileModuleInterfaceUnit",
        execution_requirements = {
            # Required so that module paths do not depend on the specific
            # sandbox instance used during precompilation.
            "no-sandbox": "1",
        },
        use_default_shell_env = False,
        env = compile_object_environment(ctx),
    )
    return file_out, cdf_out

def create_archive_library(ctx, in_files):
    """Create an archive action for an archive.

    Args:
        ctx: The rule context.
        in_files: A `depset` of input files.

    Returns:
        An output file.
    """
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    out_file = create_archive_library_outputs(ctx)
    in_files = create_archive_library_inputs(ctx, in_files)

    ctx.actions.run(
        outputs = [out_file],
        inputs = in_files,
        executable = toolchain.archiver,
        arguments = create_archive_library_args(ctx, in_files, out_file),
        mnemonic = "LlCreateArchiveLibrary",
        use_default_shell_env = False,
    )
    return out_file

def link_shared_object(ctx, in_files):
    """Create a link action for a shared object.

    Args:
        ctx: The rule context.
        in_files: A `depset` of input files.

    Returns:
        An output file.
    """
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    out_file = link_shared_object_outputs(ctx)
    in_files = link_shared_object_inputs(ctx, in_files)

    ctx.actions.run(
        outputs = [out_file],
        inputs = in_files,
        executable = toolchain.linker_wrapper,
        arguments = link_executable_args(
            ctx,
            in_files,
            out_file,
            mode = "shared_object",
        ),
        tools = linking_tools(ctx),
        mnemonic = "LlLinkSharedObject",
        use_default_shell_env = False,
        env = compile_object_environment(ctx),
    )
    return out_file

def link_executable(ctx, in_files):
    """Create a link action for an executable.

    Args:
        ctx: The rule context.
        in_files: A `depset` of input files.

    Returns:
        An output file.
    """
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    out_file = link_executable_outputs(ctx)
    in_files = link_executable_inputs(ctx, in_files)

    ctx.actions.run(
        outputs = [out_file],
        inputs = in_files,
        executable = toolchain.linker_wrapper,
        tools = linking_tools(ctx),
        arguments = link_executable_args(
            ctx,
            in_files,
            out_file,
            mode = "executable",
        ),
        mnemonic = "LlLinkExecutable",
        use_default_shell_env = False,
        env = compile_object_environment(ctx),
    )
    return out_file
