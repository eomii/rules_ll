"""# `//ll:internal_functions.bzl`

Internal functions used by `ll_binary` and `ll_library`.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//ll:providers.bzl", "LlInfo")

def get_transitive_hdrs(ctx, transitive_hdrs):
    return depset(
        transitive_hdrs,
        transitive = [dep[LlInfo].transitive_hdrs for dep in ctx.attr.deps],
    )

def get_transitive_defines(ctx, transitive_defines):
    return depset(
        transitive_defines,
        transitive = [dep[LlInfo].transitive_defines for dep in ctx.attr.deps],
    )

def get_transitive_includes(
        ctx,
        transitive_includes,
        transitive_relative_includes):
    return depset(
        transitive_includes + [
            paths.join(ctx.label.workspace_root, suffix)
            for suffix in transitive_relative_includes
        ],
        transitive = [dep[LlInfo].transitive_includes for dep in ctx.attr.deps],
    )

def get_transitive_angled_includes(
        ctx,
        transitive_angled_includes,
        transitive_relative_angled_includes):
    return depset(
        transitive_angled_includes + [
            paths.join(ctx.label.workspace_root, suffix)
            for suffix in transitive_relative_angled_includes
        ],
        transitive = [
            dep[LlInfo].transitive_angled_includes
            for dep in ctx.attr.deps
        ],
    )

def get_modules(ctx):
    return depset(
        [],
        transitive = [dep[LlInfo].modules for dep in ctx.attr.deps],
    )

def resolve_binary_deps(ctx):
    # Headers.
    transitive_hdrs = get_transitive_hdrs(ctx, [])
    headers = depset(ctx.files.hdrs, transitive = [transitive_hdrs])

    # Defines.
    transitive_defines = get_transitive_defines(ctx, [])
    defines = depset(ctx.attr.defines, transitive = [transitive_defines])

    # Includes.
    transitive_includes = get_transitive_includes(ctx, [], [])
    includes = depset(
        ctx.attr.includes + [
            paths.join(ctx.label.workspace_root, suffix)
            for suffix in ctx.attr.relative_includes
        ],
        transitive = [transitive_includes],
    )

    # Angled includes.
    transitive_angled_includes = get_transitive_angled_includes(ctx, [], [])
    angled_includes = depset(
        ctx.attr.angled_includes,
        transitive = [transitive_angled_includes],
    )

    # Modules.
    modules = get_modules(ctx)

    return (
        headers,
        defines,
        includes,
        angled_includes,
        modules,
    )

def resolve_library_deps(ctx):
    dep_angled_includes = [
        dep[LlInfo].transitive_angled_includes
        for dep in ctx.attr.deps
    ]

    # Headers.
    transitive_hdrs = get_transitive_hdrs(ctx, ctx.files.transitive_hdrs)
    headers = depset(ctx.files.hdrs, transitive = [transitive_hdrs])

    # Defines.
    transitive_defines = get_transitive_defines(
        ctx,
        ctx.attr.transitive_defines,
    )
    defines = depset(ctx.attr.defines, transitive = [transitive_defines])

    # Includes.
    transitive_includes = get_transitive_includes(
        ctx,
        ctx.attr.transitive_includes,
        ctx.attr.transitive_relative_includes,
    )
    includes = depset(
        ctx.attr.includes + [
            paths.join(ctx.label.workspace_root, suffix)
            for suffix in ctx.attr.relative_includes
        ],
        transitive = [transitive_includes],
    )

    # Angled includes.
    transitive_angled_includes = get_transitive_angled_includes(
        ctx,
        ctx.attr.transitive_angled_includes,
        ctx.attr.transitive_relative_angled_includes,
    )
    angled_includes = depset(
        ctx.attr.angled_includes + [
            paths.join(ctx.label.workspace_root, suffix)
            for suffix in ctx.attr.relative_angled_includes
        ],
        transitive = [transitive_angled_includes],
    )

    modules = get_modules(ctx)

    return (
        headers,
        defines,
        includes,
        angled_includes,
        transitive_hdrs,
        transitive_defines,
        transitive_includes,
        transitive_angled_includes,
        modules,
    )
