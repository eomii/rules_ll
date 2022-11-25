"""# `//ll:actions.bzl`

Actions wiring up inputs, outputs and tools to emit output files.

Every function in this file effectively wraps `ctx.actions.run` or
`ctx.actions.run_shell`.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load(
    "//ll:args.bzl",
    "compile_object_args",
    "create_archive_library_args",
    "link_bitcode_library_args",
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
    "link_bitcode_library_inputs",
    "link_executable_inputs",
    "link_shared_object_inputs",
)
load(
    "//ll:outputs.bzl",
    "compile_object_outputs",
    "create_archive_library_outputs",
    "link_bitcode_library_outputs",
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
        internal_bmis,
        toolchain_type):
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
            [],  # Internal BMIs can't depend on each other.
            toolchain_type,
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
            bmis,
            internal_bmis,
            toolchain_type,
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
        bmis,
        internal_bmis,
        toolchain_type):
    file_out, cdf_out = compile_object_outputs(ctx, in_file)

    ctx.actions.run(
        outputs = [file_out, cdf_out],
        inputs = compile_object_inputs(
            ctx,
            in_file,
            headers,
            bmis,
            internal_bmis,
            toolchain_type,
        ),
        executable = compiler_driver(ctx, in_file, toolchain_type),
        tools = compile_object_tools(ctx, toolchain_type),
        arguments = compile_object_args(
            ctx,
            in_file,
            file_out,
            cdf_out,
            headers,
            defines,
            includes,
            angled_includes,
            bmis,
            internal_bmis,
        ),
        mnemonic = "LlCompileObject",
        use_default_shell_env = False,
        env = compile_object_environment(ctx, toolchain_type),
    )
    return file_out, cdf_out

def precompile_interfaces(
        ctx,
        headers,
        defines,
        includes,
        angled_includes,
        bmis,
        toolchain_type,
        binary):
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
            toolchain_type,
        )
        internal_bmis.append((file_out, module_name))
        cdfs.append(cdf_out)

    # Exposed BMIs are available to direct dependents of the target. Internal
    # BMIs are available to the precompilation steps for these interfaces.
    exposed_bmis = []
    if not binary:
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
                toolchain_type,
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
        bmis,
        toolchain_type):
    file_out, cdf_out = precompile_interface_outputs(ctx, in_file)

    ctx.actions.run(
        outputs = [file_out, cdf_out],
        inputs = compile_object_inputs(
            ctx,
            in_file,
            headers,
            bmis,
            [],  # No local BMIs. we are producing these here.
            toolchain_type,
        ),
        executable = ctx.toolchains[toolchain_type].cpp_driver,
        tools = compile_object_tools(ctx, toolchain_type),
        arguments = compile_object_args(
            ctx,
            in_file,
            file_out,
            cdf_out,
            headers,
            defines,
            includes,
            angled_includes,
            bmis,
            [],  # No local BMIs. we are producing these here.
        ),
        mnemonic = "LlPrecomileModuleInterfaceUnit",
        execution_requirements = {
            # Required so that module paths do not depend on the specific
            # sandbox instance used during precompilation.
            "no-sandbox": "1",
        },
        use_default_shell_env = False,
        env = compile_object_environment(ctx, toolchain_type),
    )
    return file_out, cdf_out

def create_archive_library(
        ctx,
        in_files,
        toolchain_type):
    out_file = create_archive_library_outputs(ctx)
    in_files = create_archive_library_inputs(ctx, in_files)

    ctx.actions.run(
        outputs = [out_file],
        inputs = in_files,
        executable = ctx.toolchains[toolchain_type].archiver,
        arguments = create_archive_library_args(ctx, in_files, out_file),
        mnemonic = "LlCreateArchiveLibrary",
        use_default_shell_env = False,
    )
    return out_file

def link_shared_object(ctx, in_files, toolchain_type):
    out_file = link_shared_object_outputs(ctx)
    in_files = link_shared_object_inputs(ctx, in_files, toolchain_type)

    ctx.actions.run(
        outputs = [out_file],
        inputs = in_files,
        executable = ctx.toolchains[toolchain_type].linker_wrapper,
        arguments = link_executable_args(
            ctx,
            in_files,
            out_file,
            mode = "shared_object",
        ),
        execution_requirements = {
            # We currently link to system libraries via local_library_path.
            # This is not ideal and we ultimately need to integrate these
            # targets to the toolchain hermetically.
            "no-cache": "1",
        },
        tools = linking_tools(ctx, toolchain_type),
        mnemonic = "LlLinkSharedObject",
        use_default_shell_env = False,
    )
    return out_file

def link_bitcode_library(ctx, in_files, toolchain_type):
    out_file = link_bitcode_library_outputs(ctx)

    ctx.actions.run(
        outputs = [out_file],
        inputs = link_bitcode_library_inputs(ctx, in_files),
        executable = ctx.toolchains[toolchain_type].bitcode_linker,
        arguments = link_bitcode_library_args(ctx, in_files, out_file),
        mnemonic = "LlLinkBitcodeLibrary",
        use_default_shell_env = False,
    )
    return out_file

def link_executable(ctx, in_files, toolchain_type):
    out_file = link_executable_outputs(ctx)
    in_files = link_executable_inputs(ctx, in_files, toolchain_type)

    ctx.actions.run(
        outputs = [out_file],
        inputs = in_files,
        executable = ctx.toolchains[toolchain_type].linker_wrapper,
        tools = linking_tools(ctx, toolchain_type),
        arguments = link_executable_args(
            ctx,
            in_files,
            out_file,
            mode = "executable",
        ),
        execution_requirements = {
            # We currently link to system libraries via local_library_path.
            # This is not ideal and we ultimately need to integrate these
            # targets to the toolchain hermetically.
            "no-cache": "1",
        },
        mnemonic = "LlLinkExecutable",
        use_default_shell_env = False,
        env = compile_object_environment(ctx, toolchain_type),
    )
    return out_file
