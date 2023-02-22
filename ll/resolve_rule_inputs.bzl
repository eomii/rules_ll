"""# `//ll:resolve_rule_inputs.bzl`

Resolve the inputs to `ll_library` and `ll_binary` rules.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//ll:providers.bzl", "LlInfo")

def expand_includes(ctx, include_string):
    """Prefix `include_string` with the path to the workspace root.

    If `include_string` starts with `$(GENERATED)`, prefixes with the`GENDIR`
    path as well.
    """

    if include_string.startswith("$(GENERATED)"):
        return include_string.replace(
            "$(GENERATED)",
            paths.join(ctx.var["GENDIR"], ctx.label.workspace_root),
        )

    return paths.join(ctx.label.workspace_root, include_string)

def resolve_rule_inputs(ctx):
    """Gather the inputs for downstream actions.

    Args:
        ctx: The rule context.

    Returns:
        A tuple `(hdrs, defines, includes, angled_includes, bmis)`. See
        [//ll:actions.bzl](actions.md) for usage.
    """
    hdrs = depset(
        ctx.files.hdrs + ctx.files.exposed_hdrs,
        transitive = [dep[LlInfo].exposed_hdrs for dep in ctx.attr.deps],
    )

    defines = depset(
        ctx.attr.defines + ctx.attr.exposed_defines,
        transitive = [dep[LlInfo].exposed_defines for dep in ctx.attr.deps],
    )

    includes = depset(
        [
            expand_includes(ctx, suffix)
            for suffix in ctx.attr.includes + ctx.attr.exposed_includes
        ],
        transitive = [dep[LlInfo].exposed_includes for dep in ctx.attr.deps],
    )

    angled_includes = depset(
        ctx.attr.angled_includes + [
            expand_includes(ctx, suffix)
            for suffix in (
                ctx.attr.angled_includes +
                ctx.attr.exposed_angled_includes
            )
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
