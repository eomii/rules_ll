"""# `//ll:environment.bzl`

Action environments.
"""

def compile_object_environment(ctx, toolchain_type):
    if toolchain_type == "//ll:toolchain_type":
        return {
            "LLVM_SYMBOLIZER_PATH": ctx.toolchains[toolchain_type].symbolizer.path,
            "LINK": ctx.toolchains[toolchain_type].bitcode_linker.path,
            "LLD": ctx.toolchains[toolchain_type].linker.path,
            "PATH": "$PATH:" + ctx.toolchains[toolchain_type].linker_executable.dirname,
            "LD_LIBRARY_PATH": "$LD_LIBRARY_PATH:" + "/usr/local/cuda/lib64",
        }
    elif toolchain_type == "//ll:heterogeneous_toolchain_type":
        return {
            "LLVM_SYMBOLIZER_PATH": ctx.toolchains[toolchain_type].symbolizer.path,
            "CLANG_OFFLOAD_BUNDLER": ctx.toolchains[toolchain_type].offload_bundler.path,
            "LINK": ctx.toolchains[toolchain_type].bitcode_linker.path,
            "LLD": ctx.toolchains[toolchain_type].linker.path,
            "PATH": "$PATH:" + ctx.toolchains[toolchain_type].linker_executable.dirname,
            "LD_LIBRARY_PATH": "$LD_LIBRARY_PATH:" + "/usr/local/cuda/lib64",
        }
    elif toolchain_type == "//ll:bootstrap_toolchain_type":
        return {
            "CPLUS_INCLUDE_PATH": Label("@llvm-project").workspace_root + "/libcxx/src",
        }
    else:
        fail("Unregognized toolchain type. rules_ll supports " +
             "//ll:toolchain_type and //ll:bootstrap_toolchain_type.")
