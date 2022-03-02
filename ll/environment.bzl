"""# `//ll:environment.bzl`

Action environments.
"""

def compile_object_environment(ctx):
    if "//ll:toolchain_type" in ctx.toolchains:
        return {
            "LLVM_SYMBOLIZER_PATH": ctx.toolchains["//ll:toolchain_type"].symbolizer.path,
            "CLANG_OFFLOAD_BUNDLER": ctx.toolchains["//ll:toolchain_type"].offload_bundler.path,
            "LINK": ctx.toolchains["//ll:toolchain_type"].bitcode_linker.path,
            "LLD": ctx.toolchains["//ll:toolchain_type"].linker.path,
            "PATH": "$PATH:" + ctx.toolchains["//ll:toolchain_type"].linker_executable.dirname,
        }
    elif "//ll:bootstrap_toolchain_type" in ctx.toolchains:
        return {}
    else:
        fail("Unregognized toolchain type. rules_ll supports " +
             "//ll:toolchain_type and //ll:bootstrap_toolchain_type.")
