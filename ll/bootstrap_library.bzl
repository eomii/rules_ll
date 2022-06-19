"""# `//ll:bootstrap_library.bzl`

This rule is used by `rules_ll` to boostrap `compiler-rt`, `libcxx`,
`libcxxabi` and `libunwind`. Users should use `ll_library` instead.
"""

load("//ll:attributes.bzl", "LL_BOOTSTRAP_LIBRARY_ATTRS")
load("//ll:providers.bzl", "LlInfo")
load("//ll:internal_functions.bzl", "resolve_library_deps")
load(
    "//ll:actions.bzl",
    "compile_objects",
    "create_archive_library",
    "expose_headers",
)

def _ll_bootstrap_library_impl(ctx):
    (
        headers,
        defines,
        includes,
        angled_includes,
        transitive_hdrs,
        transitive_defines,
        transitive_includes,
        transitive_angled_includes,
    ) = resolve_library_deps(ctx)

    intermediary_objects, cdfs = compile_objects(
        ctx,
        headers = headers,
        defines = defines,
        includes = includes,
        angled_includes = angled_includes,
        toolchain_type = "//ll:bootstrap_toolchain_type",
    )

    out_files = intermediary_objects

    if ctx.attr.emit != ["archive"]:
        fail("ll_bootstrap_library does not support non-default emit options.")

    out_file = create_archive_library(
        ctx,
        in_files = intermediary_objects,
        toolchain_type = "//ll:bootstrap_toolchain_type",
    )

    return [
        DefaultInfo(files = depset([out_file])),
        LlInfo(
            transitive_hdrs = transitive_hdrs,
            transitive_defines = transitive_defines,
            transitive_includes = transitive_includes,
            transitive_angled_includes = transitive_angled_includes,
        ),
    ]

ll_bootstrap_library = rule(
    implementation = _ll_bootstrap_library_impl,
    executable = False,
    attrs = LL_BOOTSTRAP_LIBRARY_ATTRS,
    toolchains = ["//ll:bootstrap_toolchain_type"],
    output_to_genfiles = True,
    doc = """
Internal use only.

Same as ll_library, but uses a different toolchain.
""",
)
