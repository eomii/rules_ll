"""# `//ll:resolve_rule_inputs.bzl`

Input resolution for `ll_library` and `ll_binary`.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//ll:providers.bzl", "LlInfo")

def resolve_rule_inputs(ctx, mode):
    hdrs = depset(
        ctx.files.hdrs + ctx.files.exposed_hdrs,
        transitive = [dep[LlInfo].exposed_hdrs for dep in ctx.attr.deps],
    )

    defines = depset(
        ctx.attr.defines + ctx.attr.exposed_defines,
        transitive = [dep[LlInfo].exposed_defines for dep in ctx.attr.deps],
    )

    exposed_includes = (
        ctx.attr.exposed_includes if mode == "ll_library" else []
    )
    exposed_relative_includes = (
        ctx.attr.exposed_relative_includes if mode == "ll_library" else []
    )
    includes = depset(
        ctx.attr.includes + exposed_includes + [
            paths.join(ctx.label.workspace_root, suffix)
            for suffix in ctx.attr.relative_includes + exposed_relative_includes
        ],
        transitive = [dep[LlInfo].exposed_includes for dep in ctx.attr.deps],
    )

    exposed_angled_includes = (
        ctx.attr.exposed_angled_includes if mode == "ll_library" else []
    )
    exposed_relative_angled_includes = (
        ctx.attr.exposed_relative_angled_includes if mode == "ll_library" else []
    )
    angled_includes = depset(
        ctx.attr.angled_includes + exposed_angled_includes + [
            paths.join(ctx.label.workspace_root, suffix)
            for suffix in ctx.attr.relative_angled_includes + exposed_relative_angled_includes
        ],
        transitive = [
            dep[LlInfo].exposed_angled_includes
            for dep in ctx.attr.deps
        ],
    )

    bmis = depset(
        transitive = [dep[LlInfo].exposed_bmis for dep in ctx.attr.deps],
    )

    return (
        hdrs,
        defines,
        includes,
        angled_includes,
        bmis,
    )
