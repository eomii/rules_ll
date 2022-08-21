"""# `//ll:driver.bzl`

Convenience function to select the C or C++ driver for compilation.
"""

def compiler_driver(ctx, in_file, toolchain_type):
    driver = ctx.toolchains[toolchain_type].c_driver
    if in_file.extension in ["cpp", "hpp", "ipp", "cl", "cc", "cppm", "pch"]:
        driver = ctx.toolchains[toolchain_type].cpp_driver

    return driver
