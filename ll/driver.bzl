"""# `//ll:driver.bzl`

Convenience function to select the C or C++ driver for compilation.
"""

def compiler_driver(ctx, toolchain_type):
    driver = ctx.toolchains[toolchain_type].c_driver
    for src in ctx.files.srcs:
        if src.extension in ["cpp", "hpp", "ipp", "cl"]:
            driver = ctx.toolchains[toolchain_type].cpp_driver
            break

    return driver
