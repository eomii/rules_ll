"""# `//ll:driver.bzl`

Select the C or C++ driver for compile actions.
"""

def compiler_driver(ctx, in_file):
    """Return either the C or C++ driver, depending on the input file extension.

    Args:
        ctx: The rule context.
        in_file: A file.

    Returns:
        The C driver if `in_file` ends in `.c`. The C++ driver otherwise.
    """
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    driver = toolchain.c_driver
    if in_file.extension in ["cpp", "hpp", "ipp", "cl", "cc", "cppm", "pch", "cxx", "cu"]:
        driver = toolchain.cpp_driver

    return driver
