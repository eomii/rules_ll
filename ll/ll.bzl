"""# `//ll:ll.bzl`

Rules to build C and C++.

Build files should import these rules from `@rules_ll//ll:defs.bzl`.
"""

load(
    "//ll:actions.bzl",
    "compile_objects",
    "create_archive_library",
    "link_executable",
    "link_shared_object",
    "precompile_interfaces",
)
load(
    "//ll:attributes.bzl",
    "LL_BINARY_ATTRS",
    "LL_LIBRARY_ATTRS",
)
load("//ll:providers.bzl", "LlCompilationDatabaseFragmentsInfo", "LlInfo")
load("//ll:resolve_rule_inputs.bzl", "expand_includes", "resolve_rule_inputs")
load("//ll:transitions.bzl", "ll_transition")

def _ll_library_impl(ctx):
    for emit in ctx.attr.emit:
        if emit not in [
            "archive",
            "shared_object",
            "objects",
        ]:
            fail(
                """Invalid value passed to emit attribute. Allowed values are
                 "archive", "shared_object", "objects". Got {}.
                 """.format(emit),
            )

    (
        headers,
        defines,
        includes,
        angled_includes,
        bmis,
    ) = resolve_rule_inputs(ctx)

    out_files = []

    out_cdfs = []

    # Interfaces that are to be precompiled are taken directly from ctx and not
    # from an argument to this function.
    internal_bmis, exposed_bmis, cdfs = precompile_interfaces(
        ctx,
        headers = headers,
        defines = defines,
        includes = includes,
        angled_includes = angled_includes,
        bmis = bmis,
        precompile_exposed = True,
    )

    out_cdfs += cdfs

    intermediary_objects, cdfs = compile_objects(
        ctx,
        headers = headers,
        defines = defines,
        includes = includes,
        angled_includes = angled_includes,
        bmis = bmis,
        internal_bmis = internal_bmis + exposed_bmis,
    )

    out_cdfs += cdfs

    if "archive" in ctx.attr.emit:
        out_files.append(
            create_archive_library(
                ctx,
                in_files = intermediary_objects,
            ),
        )
    if "shared_object" in ctx.attr.emit:
        out_files.append(
            link_shared_object(
                ctx,
                in_files = intermediary_objects,
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
            exposed_hdrs = depset(ctx.files.exposed_hdrs),
            exposed_defines = depset(ctx.attr.exposed_defines),
            exposed_includes = depset(
                [
                    expand_includes(ctx, suffix)
                    for suffix in ctx.attr.exposed_includes
                ],
            ),
            exposed_angled_includes = depset(
                [
                    expand_includes(ctx, suffix)
                    for suffix in ctx.attr.exposed_angled_includes
                ],
            ),
            exposed_bmis = depset(exposed_bmis + internal_bmis),
        ),
        LlCompilationDatabaseFragmentsInfo(
            cdfs = depset(out_cdfs, transitive = transitive_cdfs),
        ),
        coverage_common.instrumented_files_info(
            ctx,
            dependency_attributes = ["deps", "data"],
            source_attributes = [
                "srcs",
                "hdrs",
                "exposed_hdrs",
                "exposed_interfaces",
                "interfaces",
            ],
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
    (
        headers,
        defines,
        includes,
        angled_includes,
        bmis,
    ) = resolve_rule_inputs(ctx)

    out_cdfs = []

    internal_bmis, exposed_bmis, cdfs = precompile_interfaces(
        ctx,
        headers = headers,
        defines = defines,
        includes = includes,
        angled_includes = angled_includes,
        bmis = bmis,
        precompile_exposed = False,
    )

    out_cdfs += cdfs

    intermediary_objects, cdfs = compile_objects(
        ctx,
        headers = headers,
        defines = defines,
        includes = includes,
        angled_includes = angled_includes,
        bmis = bmis,
        internal_bmis = internal_bmis + exposed_bmis,
    )
    out_cdfs += cdfs

    out_file = link_executable(
        ctx,
        in_files = intermediary_objects + ctx.files.deps,
    )

    transitive_cdfs = [
        dep[LlCompilationDatabaseFragmentsInfo].cdfs
        for dep in ctx.attr.deps
    ]

    runfiles = None

    if ctx.attr.compilation_mode == "hip_amdgpu":
        toolchain = ctx.toolchains["//ll:toolchain_type"]
        runfiles = ctx.runfiles(files = toolchain.hip_runtime)

    return [
        DefaultInfo(
            files = depset([out_file]),
            executable = out_file,
            runfiles = runfiles,
        ),
        LlCompilationDatabaseFragmentsInfo(
            cdfs = depset(out_cdfs, transitive = transitive_cdfs),
        ),
        coverage_common.instrumented_files_info(
            ctx,
            dependency_attributes = ["deps", "data"],
            source_attributes = [
                "srcs",
                "hdrs",
                "exposed_hdrs",
                "exposed_interfaces",
                "interfaces",
            ],
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

ll_test = rule(
    implementation = _ll_binary_impl,
    test = True,
    attrs = LL_BINARY_ATTRS,
    cfg = ll_transition,
    toolchains = [
        "//ll:toolchain_type",
    ],
    doc = """
Testable wrapper around `ll_binary`.

Consider using this rule over skylib's `native_test` targets to propagate shared
libraries to the test invocations.

Example:

  ```python
  ll_test(
      name = "amdgpu_test",
      srcs = ["my_executable.cpp"],
      compilation_mode = "hip_amdgpu",
      compile_flags = OFFLOAD_ALL_AMDGPU + [
          "-std=c++20",
      ],
      tags = ["amdgpu"],  # Not required, but makes grouping tests easier.
  )
  ```
""",
)
