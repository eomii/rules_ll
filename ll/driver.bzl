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

    driver = None
    if in_file.extension in ["c", "S"]:
        driver = toolchain.c_driver
    elif in_file.extension in [
        "cc",
        "cl",
        "cpp",
        "cppm",
        "cu",
        "cxx",
        "hip",
        "hpp",
        "ipp",
        "mpp",
        "pch",
        "pcm",
    ]:
        driver = toolchain.cpp_driver
    else:
        fail(
            "Unknown filetype for {}. Don't know what driver to choose.".format(
                in_file,
            ),
        )

    return driver
