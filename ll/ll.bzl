"""# `//ll:ll.bzl`

Rules for building C/C++ with an upstream LLVM/Clang toolchain.

Build files should import these rules via `@rules_ll//ll:defs.bzl`.
"""

load("//ll:providers.bzl", "LlCompilationDatabaseFragmentsInfo", "LlInfo")
load("//ll:transitions.bzl", "ll_transition")
load(
    "//ll:internal_functions.bzl",
    "resolve_binary_deps",
    "resolve_library_deps",
)
load(
    "//ll:actions.bzl",
    "compile_objects",
    "create_archive_library",
    "expose_headers",
    "link_bitcode_library",
    "link_executable",
    "link_shared_object",
)
load(
    "//ll:attributes.bzl",
    "LL_BINARY_ATTRS",
    "LL_LIBRARY_ATTRS",
)

def select_toolchain_type(ctx):
    return "//ll:toolchain_type"

def _ll_library_impl(ctx):
    for emit in ctx.attr.emit:
        if emit not in ["archive", "shared_object", "bitcode", "objects"]:
            fail(
                """Invalid value passed to emit attribute. Allowed valuse are

                 "archive", "shared_object", "bitcode", "objects". Got {}.
                 """.format(emit),
            )

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
        toolchain_type = select_toolchain_type(ctx),
    )

    out_files = []
    if "archive" in ctx.attr.emit:
        out_files.append(
            create_archive_library(
                ctx,
                in_files = intermediary_objects,
                toolchain_type = select_toolchain_type(ctx),
            ),
        )
    if "shared_object" in ctx.attr.emit:
        out_files.append(
            link_shared_object(
                ctx,
                in_files = intermediary_objects,
                toolchain_type = select_toolchain_type(ctx),
            ),
        )
    if "bitcode" in ctx.attr.emit:
        out_files.append(
            link_bitcode_library(
                ctx,
                in_files = intermediary_objects,
                toolchain_type = select_toolchain_type(ctx),
            ),
        )
    if "objects" in ctx.attr.emit:
        out_files += intermediary_objects

    transitive_cdfs = [
        dep[LlCompilationDatabaseFragmentsInfo].cdfs
        for dep in ctx.attr.deps
    ]

    return [
        DefaultInfo(
            files = depset(out_files),
        ),
        LlInfo(
            transitive_hdrs = transitive_hdrs,
            transitive_defines = transitive_defines,
            transitive_includes = transitive_includes,
            transitive_angled_includes = transitive_angled_includes,
        ),
        LlCompilationDatabaseFragmentsInfo(
            cdfs = depset(cdfs, transitive = transitive_cdfs),
        ),
    ]

ll_library = rule(
    implementation = _ll_library_impl,
    executable = False,
    attrs = LL_LIBRARY_ATTRS,
    output_to_genfiles = True,
    incompatible_use_toolchain_transition = True,
    cfg = ll_transition,
    toolchains = [
        "//ll:toolchain_type",
    ],
    doc = """
Creates a static archive.

Example:

  ```python
  ll_library(
      srcs = ["my_library.cpp"],
  )
  ```
""",
)

def _ll_binary_impl(ctx):
    headers, defines, includes, angled_includes = resolve_binary_deps(ctx)

    intermediary_objects, cdfs = compile_objects(
        ctx,
        headers = headers,
        defines = defines,
        includes = includes,
        angled_includes = angled_includes,
        toolchain_type = select_toolchain_type(ctx),
    )

    out_file = link_executable(
        ctx,
        in_files = intermediary_objects + ctx.files.deps,
        toolchain_type = select_toolchain_type(ctx),
    )

    transitive_cdfs = [
        dep[LlCompilationDatabaseFragmentsInfo].cdfs
        for dep in ctx.attr.deps
    ]

    return [
        DefaultInfo(
            files = depset([out_file]),
            executable = out_file,
        ),
        LlCompilationDatabaseFragmentsInfo(
            cdfs = depset(cdfs, transitive = transitive_cdfs),
        ),
    ]

ll_binary = rule(
    implementation = _ll_binary_impl,
    executable = True,
    attrs = LL_BINARY_ATTRS,
    cfg = ll_transition,
    toolchains = [
        "//ll:toolchain_type",
    ],
    doc = """
Creates an executable.

Example:

  ```python
  ll_binary(
      srcs = ["my_executable.cpp"],
  )
  ```
""",
)
