"""# `//ll:driver.bzl`

Select the C or C++ driver for compile actions.
"""

def compiler_driver(ctx, in_file, toolchain_type):
    driver = ctx.toolchains[toolchain_type].c_driver
    if in_file.extension in ["cpp", "hpp", "ipp", "cl", "cc", "cppm", "pch", "cxx", "cu"]:
        driver = ctx.toolchains[toolchain_type].cpp_driver

    return driver
