"""# `//ll:environment.bzl`

Action environments.
"""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

def compile_object_environment(ctx, toolchain_type):
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value

    if config == "cpp":
        return {
            "LLVM_SYMBOLIZER_PATH": ctx.toolchains[toolchain_type].symbolizer.path,
            "LINK": ctx.toolchains[toolchain_type].bitcode_linker.path,
            "LLD": ctx.toolchains[toolchain_type].linker.path,
            "PATH": "$PATH:" + ctx.toolchains[toolchain_type].linker_executable.dirname,
        }
    elif config in ["cuda_nvidia", "hip_nvidia"]:
        return {
            "LLVM_SYMBOLIZER_PATH": ctx.toolchains[toolchain_type].symbolizer.path,
            "CLANG_OFFLOAD_BUNDLER": ctx.toolchains[toolchain_type].offload_bundler.path,
            "LINK": ctx.toolchains[toolchain_type].bitcode_linker.path,
            "LLD": ctx.toolchains[toolchain_type].linker.path,
            "PATH": "$PATH:" + ctx.toolchains[toolchain_type].linker_executable.dirname,
        }
    elif config == "bootstrap":
        return {
            "CPLUS_INCLUDE_PATH": Label("@llvm-project").workspace_root + "/libcxx/src",
        }
    else:
        fail("Unregognized toolchain type. rules_ll supports " +
             "//ll:toolchain_type and //ll:bootstrap_toolchain_type.")
