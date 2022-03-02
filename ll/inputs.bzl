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
            ctx.toolchains["//ll:toolchain_type"].builtin_includes +
            ctx.toolchains["//ll:toolchain_type"].cpp_stdlib,
            transitive = [headers],
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

def link_executable_inputs(ctx, in_files, libraries):
    if "//ll:toolchain_type" in ctx.toolchains:
        return depset(
            in_files +
            ctx.toolchains["//ll:toolchain_type"].compiler_runtime +
            ctx.toolchains["//ll:toolchain_type"].unwind_library +
            ctx.toolchains["//ll:toolchain_type"].cpp_stdlib +
            ctx.toolchains["//ll:toolchain_type"].local_crt,
            transitive = [libraries],
        )
    else:
        fail("Can only link when using \"//ll:toolchain_type\".")

def link_bitcode_library_inputs(ctx, in_files, libraries):
    if "//ll:toolchain_type" in ctx.toolchains:
        return depset(in_files, transitive = [libraries])
    else:
        fail("Can only link bitcode when using \"//ll:toolchain_type\".")
