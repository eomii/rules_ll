"""# `//ll:tools.bzl`

Tools used by actions.
"""

def compile_object_tools(ctx):
    """Tools for use in compile actions.

    Args:
        ctx: The rule context.

    Returns:
        A list of labels.
    """
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    return [
        toolchain.bitcode_linker,
        toolchain.c_driver,
        toolchain.cpp_driver,
        toolchain.linker,
        toolchain.linker_executable,
        toolchain.linker_wrapper,
        toolchain.objcopy,
        toolchain.offload_bundler,
        toolchain.offload_packager,
        toolchain.opt,
        toolchain.symbolizer,
    ]

def linking_tools(ctx):
    """Tools for use in link actions.

    Args:
        ctx: The rule context.

    Returns:
        A list of labels.
    """
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    return [
        toolchain.linker,
        toolchain.linker_executable,
        toolchain.linker_wrapper,
        toolchain.objcopy,
    ] + (
        toolchain.address_sanitizer +
        toolchain.leak_sanitizer +
        toolchain.memory_sanitizer +
        toolchain.profile +
        toolchain.thread_sanitizer +
        toolchain.undefined_behavior_sanitizer
    )
