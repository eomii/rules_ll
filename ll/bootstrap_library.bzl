load("//ll:ll.bzl", "DEFAULT_ATTRS")
load("//ll:providers.bzl", "LlInfo")
load(
    "//ll:internal_functions.bzl",
    "create_archive_library",
    "create_compile_inputs",
    "expose_headers",
)

def _ll_bootstrap_library_impl(ctx):
    (
        headers,
        libraries,
        defines,
        includes,
        transitive_headers,
        transitive_defines,
        transitive_includes,
    ) = create_compile_inputs(ctx)

    out_file, _ = create_archive_library(
        ctx,
        headers = headers,
        libraries = libraries,
        defines = defines,
        includes = includes,
        toolchain_type = "//ll:bootstrap_toolchain_type",
    )

    exposed_headers = expose_headers(ctx)

    return [
        DefaultInfo(files = depset([out_file] + exposed_headers)),
        LlInfo(
            transitive_headers = transitive_headers,
            libraries = depset([out_file], transitive = [libraries]),
            transitive_defines = transitive_defines,
            transitive_includes = transitive_includes,
        ),
    ]

ll_bootstrap_library = rule(
    implementation = _ll_bootstrap_library_impl,
    executable = False,
    attrs = DEFAULT_ATTRS,
    toolchains = ["//ll:bootstrap_toolchain_type"],
    output_to_genfiles = True,
    doc = """
Internal use only.

Same as ll_library, but uses a different toolchain.
""",
)
