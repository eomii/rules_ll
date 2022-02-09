load("//ll:providers.bzl", "LlInfo")
load(
    "//ll:internal_functions.bzl",
    "create_archive_library",
    "create_compile_inputs",
    "create_executable",
    "expose_headers",
)

DEFAULT_ATTRS = {
    "deps": attr.label_list(
        doc = """The dependencies for this target.

        Every dependency needs to be an `ll_library`.""",
        providers = [LlInfo],
    ),
    "srcs": attr.label_list(
        doc = """Compilable source files for this target.

        Only compilable files and object files `[".o", ".S", ".c", ".cpp"]` are
        allowed here.

        Headers should be placed in the `hdrs` attribute.
        """,
        allow_files = [".o", ".S", ".c", ".cpp"],
    ),
    "hdrs": attr.label_list(
        doc = """Header files for this target.

        Headers in this attribute will not be exported, i.e. any generated
        include paths are only used for this target.

        When including header files as `#include "some/path/myheader.h"` their
        include paths need to be specified in the `includes` attribute as well.
        """,
        allow_files = True,
    ),
    "transitive_hdrs": attr.label_list(
        doc = """Transitive headers for this target.

        Any transitive headers will be exported (copied) to the build directory.

        Transitive headers are available to depending downstream targets.
        """,
        allow_files = True,
    ),
    "defines": attr.string_list(
        doc = """Additional defines for this target.

        A list of strings `["MYDEFINE_1", "MYDEFINE_2"]` will add
        `-DMYDEFINE_1 -DMYDEFINE_2` to the compile command line.

        Defines in this attribute are only used for the current target.
        """,
    ),
    "transitive_defines": attr.string_list(
        doc = """Additional transitive defines for this target.

        These defines will be defined by all depending downstream targets.
        """,
    ),
    "includes": attr.string_list(
        doc = """Additional include paths for this target.

        When including a header not via `#include "header.h"`, but via
        `#include "subdir/header.h"`, the include path needs to be added here in
        addition to making the header available in the `hdrs` attribute.
        """,
    ),
    "transitive_includes": attr.string_list(
        doc = """Additional transitive include paths for this target.

        Includes in this attribute will be added to the compile command line
        arguments for all downstream targets.
        """,
    ),
    "compile_flags": attr.string_list(
        doc = """Additional flags for the compiler.

        A list of strings `["-O3", "-std=c++20"]` will be appended to the
        compile command line arguments as `-O3 -std=c++20`.

        Only used for this target.
        """,
    ),
    "link_flags": attr.string_list(
        doc = """Additional flags for the linker.

        This is the place for adding library search paths and external link
        targets.

        Assuming you have a library `/some/path/libmylib.a` on your host system,
        you can make `mylib.a` available to the linker by passing
        `["-L/some/path", "-lmylib"]` to this attribute.

        Only used for this target. Only used by `ll_binary`, since `ll_library`
        does not invoke the linker.
        """,
    ),
    "proprietary": attr.bool(
        doc = """Setting this to True will disable static linking of glibc.

        This attribute will be removed as soon as `rules_ll` uses LLVM's `libc`.
        """,
        default = False,
    ),
}

def _ll_library_impl(ctx):
    (
        headers,
        libraries,
        defines,
        includes,
        transitive_headers,
        transitive_defines,
        transitive_includes,
    ) = create_compile_inputs(ctx)

    out_file = create_archive_library(
        ctx,
        headers = headers,
        libraries = libraries,
        defines = defines,
        includes = includes,
        toolchain_type = "//ll:toolchain_type",
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

ll_library = rule(
    implementation = _ll_library_impl,
    executable = False,
    attrs = DEFAULT_ATTRS,
    toolchains = ["//ll:toolchain_type"],
    output_to_genfiles = True,
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
    headers, libraries, defines, includes, _, _, _ = create_compile_inputs(ctx)

    out_file = create_executable(
        ctx,
        headers = headers,
        libraries = libraries,
        defines = defines,
        includes = includes,
    )

    return [DefaultInfo(
        files = depset([out_file]),
        executable = out_file,
    )]

ll_binary = rule(
    implementation = _ll_binary_impl,
    executable = True,
    attrs = DEFAULT_ATTRS,
    toolchains = ["//ll:toolchain_type"],
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
