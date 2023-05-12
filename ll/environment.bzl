"""# `//ll:environment.bzl`

Environment variables for use in compile and link actions.
"""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

def compile_object_environment(ctx):
    """Set environment variables for compile and link actions.

    For end users this depends on `compilation_mode` in the `ll_library` and
    `ll_binary` rules.

    Args:
        ctx: The rule context.

    Returns:
        A `dict` for use in the `environment` of an action.
    """
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    if config in ["cpp", "omp_cpu"]:
        return {
            "LINK": toolchain.bitcode_linker.path,
            "LLD": toolchain.linker.path,
            "LLVM_SYMBOLIZER_PATH": toolchain.symbolizer.path,
            "PATH": ":".join([
                toolchain.linker.dirname,
                toolchain.linker_executable.dirname,
            ]),
        }
    elif config in ["wasm"]:
        return {
            "LINK": toolchain.bitcode_linker.path,
            "LLD": toolchain.wasm_linker.path,
            "LLVM_SYMBOLIZER_PATH": toolchain.symbolizer.path,
            "PATH": ":".join([
                toolchain.linker.dirname,
                toolchain.linker_executable.dirname,
            ]),
        }
    elif config in ["cuda_nvptx", "hip_amdgpu", "hip_nvptx"]:
        return {
            "CLANG_OFFLOAD_BUNDLER": toolchain.offload_bundler.path,
            "LINK": toolchain.bitcode_linker.path,
            "LLD": toolchain.linker.path,
            "LLVM_SYMBOLIZER_PATH": toolchain.symbolizer.path,
            "PATH": ":".join([
                toolchain.linker.dirname,
                toolchain.linker_executable.dirname,
                toolchain.objcopy.dirname,  # Offload-bundler looks here.
            ]),
            "HIPSCYL_DEBUG_LEVEL": "4",
        }
    elif config == "bootstrap":
        return {
            "LLVM_SYMBOLIZER_PATH": toolchain.symbolizer.path,
        }
    else:
        fail("Unregognized toolchain configuration.")
