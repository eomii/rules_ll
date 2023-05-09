"""# `//ll:tools.bzl`

Tools used by actions.
"""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

# TODO: Would it be a bad idea to add *all* tools to *every* action?
#       The ll_toolchain target already decides whether the toolchain symbols
#       are actually populated, so this wouldn't lead to unnecessary builds.

def compile_object_tools(ctx):
    """Tools for use in compile actions.

    Args:
        ctx: The rule context.

    Returns:
        A list of labels.
    """
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    tools = [
        toolchain.symbolizer,
    ]

    if config == "bootstrap":
        return tools

    tools += [
        toolchain.bitcode_linker,
        toolchain.linker,
        toolchain.linker_executable,
        toolchain.linker_wrapper,
        toolchain.objcopy,
        toolchain.opt,
    ]

    if config in ["cpp", "omp_cpu"]:
        return tools

    if config in ["cuda_nvptx", "hip_nvptx", "hip_amdgpu", "sycl_amdgpu"]:
        return tools + [
            toolchain.offload_bundler,
            toolchain.offload_packager,
        ]

    if config in ["sycl_cpu", "sycl_amdgpu"]:
        return tools + [toolchain.sycl_plugin]

    fail("Unregognized toolchain toolchain configuration.")

def linking_tools(ctx):
    """Tools for use in link actions.

    Args:
        ctx: The rule context.

    Returns:
        A list of labels.
    """
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    if config == "bootstrap":
        fail("Cannot link with bootstrap toolchain.")

    return [
        toolchain.linker,
        toolchain.linker_executable,
        toolchain.linker_wrapper,
        toolchain.objcopy,
    ] + (
        toolchain.address_sanitizer +
        toolchain.leak_sanitizer +
        toolchain.thread_sanitizer +
        toolchain.memory_sanitizer +
        toolchain.undefined_behavior_sanitizer +
        toolchain.profile
    )
