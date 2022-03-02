"""# `//ll:internal_functions.bzl`

Internal functions used by `ll_binary` and `ll_library`.
"""

load("//ll:providers.bzl", "LlInfo")

def resolve_deps(ctx):
    dep_headers = [dep[LlInfo].transitive_headers for dep in ctx.attr.deps]
    dep_libraries = [dep[LlInfo].libraries for dep in ctx.attr.deps]
    dep_defines = [dep[LlInfo].transitive_defines for dep in ctx.attr.deps]
    dep_includes = [dep[LlInfo].transitive_includes for dep in ctx.attr.deps]

    # Headers.
    transitive_headers = depset(
        ctx.files.transitive_hdrs,
        transitive = dep_headers,
    )
    headers = depset(ctx.files.hdrs, transitive = [transitive_headers])

    # Libraries.
    libraries = depset([], transitive = dep_libraries)

    # Defines.
    transitive_defines = depset(
        ctx.attr.transitive_defines,
        transitive = dep_defines,
    )
    defines = depset(ctx.attr.defines, transitive = [transitive_defines])

    # Includes.
    transitive_includes = depset(
        ctx.attr.transitive_includes,
        transitive = dep_includes,
    )
    includes = depset(ctx.attr.includes, transitive = [transitive_includes])

    return (
        headers,
        libraries,
        defines,
        includes,
        transitive_headers,
        transitive_defines,
        transitive_includes,
    )
