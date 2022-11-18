"""# `//ll:tools.bzl`

Tools used by actions.
"""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

def compile_object_tools(ctx, toolchain_type):
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value

    tools = [
        ctx.toolchains[toolchain_type].symbolizer,
    ]

    if config == "bootstrap":
        return tools

    tools += [
        ctx.toolchains[toolchain_type].bitcode_linker,
        ctx.toolchains[toolchain_type].linker,
        ctx.toolchains[toolchain_type].linker_executable,
        ctx.toolchains[toolchain_type].linker_wrapper,
    ]

    if config == "cpp":
        return tools

    if config in ["cuda_nvidia", "hip_nvidia"]:
        return tools + [
            ctx.toolchains[toolchain_type].offload_bundler,
            ctx.toolchains[toolchain_type].offload_packager,
        ]

    if config in ["sycl_cpu", "sycl_cuda"]:
        return tools + [
            ctx.toolchains[toolchain_type].hipsycl_plugin,
            ctx.toolchains[toolchain_type].offload_bundler,
            ctx.toolchains[toolchain_type].offload_packager,
            ctx.toolchains[toolchain_type].hipsycl_omp_backend,
            ctx.toolchains[toolchain_type].hipsycl_cuda_backend,
        ]

    fail("Unregognized toolchain toolchain configuration.")

def linking_tools(ctx, toolchain_type):
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value

    if config == "bootstrap":
        fail("Cannot link with bootstrap toolchain.")

    return [
        ctx.toolchains[toolchain_type].linker,
        ctx.toolchains[toolchain_type].linker_executable,
        ctx.toolchains[toolchain_type].linker_wrapper,
        ctx.toolchains[toolchain_type].local_library_path,
    ] + (
        ctx.toolchains[toolchain_type].address_sanitizer +
        ctx.toolchains[toolchain_type].leak_sanitizer +
        ctx.toolchains[toolchain_type].thread_sanitizer +
        ctx.toolchains[toolchain_type].memory_sanitizer +
        ctx.toolchains[toolchain_type].undefined_behavior_sanitizer
    )
