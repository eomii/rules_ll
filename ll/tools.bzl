"""# `//ll:tools.bzl`

Tools used by actions.
"""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

def compile_object_tools(ctx, toolchain_type):
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value

    if config == "cpp":
        return [
            ctx.toolchains[toolchain_type].symbolizer,
            ctx.toolchains[toolchain_type].bitcode_linker,
            ctx.toolchains[toolchain_type].linker,
            ctx.toolchains[toolchain_type].linker_executable,
        ]
    elif config in ["cuda_nvidia", "hip_nvidia"]:
        return [
            ctx.toolchains[toolchain_type].offload_bundler,
            ctx.toolchains[toolchain_type].symbolizer,
            ctx.toolchains[toolchain_type].bitcode_linker,
            ctx.toolchains[toolchain_type].linker,
            ctx.toolchains[toolchain_type].linker_executable,
        ]
    elif config == "sycl_cpu":
        return [
            ctx.toolchains[toolchain_type].symbolizer,
            ctx.toolchains[toolchain_type].bitcode_linker,
            ctx.toolchains[toolchain_type].linker,
            ctx.toolchains[toolchain_type].linker_executable,
            ctx.toolchains[toolchain_type].hipsycl_plugin,
        ]
    elif config == "bootstrap":
        return [
            ctx.toolchains[toolchain_type].symbolizer,
        ]
    else:
        fail("Unregognized toolchain toolchain configuration.")

def linking_tools(ctx, toolchain_type):
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value

    if config == "bootstrap":
        fail("Cannot link with bootstrap toolchain.")

    return [
        ctx.toolchains[toolchain_type].linker,
        ctx.toolchains[toolchain_type].local_library_path,
    ] + (
        ctx.toolchains[toolchain_type].address_sanitizer +
        ctx.toolchains[toolchain_type].leak_sanitizer +
        ctx.toolchains[toolchain_type].thread_sanitizer +
        ctx.toolchains[toolchain_type].memory_sanitizer +
        ctx.toolchains[toolchain_type].undefined_behavior_sanitizer
    )
