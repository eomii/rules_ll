"""# `//ll:actions.bzl`

Actions wiring up inputs, outputs and tools to emit output files.

Every function in this file effectively wraps `ctx.actions.run` or
`ctx.actions.run_shell`.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load(
    "//ll:inputs.bzl",
    "compilable_sources",
    "compile_object_inputs",
    "create_archive_library_inputs",
    "link_bitcode_library_inputs",
    "link_executable_inputs",
)
load(
    "//ll:outputs.bzl",
    "compile_object_outputs",
    "create_archive_library_outputs",
    "link_bitcode_library_outputs",
    "link_executable_outputs",
)
load(
    "//ll:args.bzl",
    "compile_object_args",
    "create_archive_library_args",
    "expose_headers_args",
    "link_bitcode_library_args",
    "link_executable_args",
)
load(
    "//ll:tools.bzl",
    "compile_object_tools",
)
load(
    "//ll:driver.bzl",
    "compiler_driver",
)
load(
    "//ll:environment.bzl",
    "compile_object_environment",
)

def expose_headers(ctx):
    headers_to_expose = ctx.files.transitive_hdrs
    exposed_hdrs = []

    for in_file in headers_to_expose:
        build_file_path = paths.join(
            ctx.label.workspace_root,
            paths.dirname(ctx.build_file_path),
        )
        relative_hdr_path = paths.relativize(in_file.path, build_file_path)
        out_file = ctx.actions.declare_file(relative_hdr_path)

        ctx.actions.run_shell(
            outputs = [out_file],
            inputs = [in_file],
            command = "cp $1 $2",
            arguments = expose_headers_args(ctx, in_file, out_file),
            mnemonic = "LlExposeHeaders",
            use_default_shell_env = False,
        )
        exposed_hdrs += [out_file]
    return exposed_hdrs

def compile_objects(
        ctx,
        headers = [],
        defines = [],
        includes = [],
        angled_includes = [],
        toolchain_type = "//ll:toolchain_type"):
    in_files = compilable_sources(ctx)
    out_files = []
    cdfs = []

    for in_file in in_files:
        file_out, cdf_out = compile_object(
            ctx,
            in_file,
            headers,
            defines,
            includes,
            angled_includes,
            toolchain_type,
        )
        out_files += [file_out]
        cdfs += [cdf_out]

    return out_files, cdfs

def compile_object(ctx, in_file, headers, defines, includes, angled_includes, toolchain_type):
    file_out, cdf_out = compile_object_outputs(ctx, in_file)

    ctx.actions.run(
        outputs = [file_out, cdf_out],
        inputs = compile_object_inputs(ctx, headers),
        executable = compiler_driver(ctx, toolchain_type),
        tools = compile_object_tools(ctx),
        arguments = compile_object_args(
            ctx,
            in_file,
            file_out,
            cdf_out,
            headers,
            defines,
            includes,
            angled_includes,
        ),
        mnemonic = "LlCompileObject",
        use_default_shell_env = False,
        env = compile_object_environment(ctx),
    )
    return file_out, cdf_out

def create_archive_library(
        ctx,
        in_files = [],
        toolchain_type = "//ll:toolchain_type"):
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

def link_bitcode_library(ctx, in_files, toolchain_type = "//ll:toolchain_type"):
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

def link_executable(ctx, in_files, toolchain_type = "//ll:toolchain_type"):
    out_file = link_executable_outputs(ctx)

    ctx.actions.run(
        outputs = [out_file],
        inputs = link_executable_inputs(ctx, in_files),
        executable = ctx.toolchains[toolchain_type].linker,
        tools = [
            ctx.toolchains[toolchain_type].linker,
        ],
        arguments = link_executable_args(ctx, in_files, out_file),
        mnemonic = "LlLinkExecutable",
        use_default_shell_env = False,
        env = compile_object_environment(ctx),
    )
    return out_file
