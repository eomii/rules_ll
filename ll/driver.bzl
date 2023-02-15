"""# `//ll:driver.bzl`

Select the C or C++ driver for compile actions.
"""

def compiler_driver(ctx, in_file):
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    driver = toolchain.c_driver
    if in_file.extension in ["cpp", "hpp", "ipp", "cl", "cc", "cppm", "pch", "cxx", "cu"]:
        driver = toolchain.cpp_driver

    return driver
