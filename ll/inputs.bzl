"""# `//ll:inputs.bzl`

Action inputs.
"""

load("//ll:providers.bzl", "LlInfo")

def compilable_sources(ctx):
    compilable_extensions = ["ll", "c", "cl", "cpp", "S"]
    return [
        src
        for src in ctx.files.srcs
        if src.extension in compilable_extensions
    ]

def compile_object_inputs(ctx, headers):
    if "//ll:toolchain_type" in ctx.toolchains:
        return depset(
            ctx.files.srcs +
            ctx.files.data +
            ctx.toolchains["//ll:toolchain_type"].builtin_includes,
            transitive = [
                headers,
                ctx.toolchains["//ll:toolchain_type"].cpp_stdhdrs.files,
            ],
        )
    elif "//ll:bootstrap_toolchain_type" in ctx.toolchains:
        return depset(
            ctx.files.srcs +
            ctx.files.data +
            ctx.toolchains["//ll:bootstrap_toolchain_type"].builtin_includes,
            transitive = [headers],
        )
    else:
        fail("Unregognized toolchain type. rules_ll supports " +
             "//ll:toolchain_type and //ll:bootstrap_toolchain_type.")

def create_archive_library_inputs(ctx, in_files):
    return depset(in_files + ctx.files.deps)

def link_executable_inputs(ctx, in_files):
    if "//ll:toolchain_type" in ctx.toolchains:
        return depset(
            in_files +
            ctx.files.deps +
            ctx.files.libraries +
            ctx.toolchains["//ll:toolchain_type"].local_crt,
            transitive = [
                ctx.toolchains["//ll:toolchain_type"].cpp_stdlib.files,
                ctx.toolchains["//ll:toolchain_type"].unwind_library.files,
                ctx.toolchains["//ll:toolchain_type"].cpp_abi.files,
                ctx.toolchains["//ll:toolchain_type"].compiler_runtime.files,
            ],
        )
    else:
        fail("Can only link when using \"//ll:toolchain_type\".")

def link_bitcode_library_inputs(ctx, in_files):
    if "//ll:toolchain_type" in ctx.toolchains:
        return depset(in_files + ctx.files.deps + ctx.files.bitcode_libraries)
    else:
        fail("Can only link bitcode when using \"//ll:toolchain_type\".")
