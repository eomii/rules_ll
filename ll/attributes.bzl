"""# `//ll:attributes.bzl`

Attribute dictionaries for `ll_*` rules.
"""

load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("//ll:providers.bzl", "LlInfo")

DEFAULT_ATTRS = {
    "deps": attr.label_list(
        doc = """The dependencies for this target.

        Every dependency needs to be an `ll_library`.""",
        providers = [LlInfo],
    ),
    "data": attr.label_list(
        doc = """Additional files made available to the sandboxed actions
        executed within this rule. These files are not appended to the default
        line arguments, but are part of the inputs to the actions and may be
        added to command line arguments manually via the `includes`,
        and `compile_flags` (for `ll_binary also `link_flags`) attributes.

        This attribute may be used to make intermediary outputs from non-ll
        targets (e.g. from `rules_cc` or `filegroup`) available to the rule.
        """,
        allow_files = True,
    ),
    "srcs": attr.label_list(
        doc = """Compilable source files for this target.

        Only compilable files and object files
        `[".ll", ".o", ".S", ".c", ".cl", ".cpp"]` are allowed here.

        Headers should be placed in the `hdrs` attribute.
        """,
        allow_files = [".ll", ".o", ".S", ".c", ".cl", ".cpp"],
    ),
    "hdrs": attr.label_list(
        doc = """Header files for this target.

        Headers in this attribute will not be exported, i.e. any generated
        include paths are only used for this target and the header files are
        not made available to downstream targets.

        When including header files as `#include "some/path/myheader.h"` their
        include paths need to be specified in the `includes` attribute as well.
        """,
        allow_files = True,
    ),
    "defines": attr.string_list(
        doc = """Additional defines for this target.

        A list of strings `["MYDEFINE_1", "MYDEFINE_2"]` will add
        `-DMYDEFINE_1 -DMYDEFINE_2` to the compile command line.

        Only used for this target.
        """,
    ),
    "includes": attr.string_list(
        doc = """Additional include paths for this target.

        When including a header not via `#include "header.h"`, but via
        `#include "subdir/header.h"`, the include path needs to be added here in
        addition to making the header available in the `hdrs` attribute.

        Only used for this target.
        """,
    ),
    "compile_flags": attr.string_list(
        doc = """Additional flags for the compiler.

        A list of strings `["-O3", "-std=c++20"]` will be appended to the
        compile command line arguments as `-O3 -std=c++20`.

        Flag pairs like `-Xclang -somearg` need to be split into separate flags
        `["-Xclang", "-somearg"]`.

        Only used for this target.
        """,
    ),
}

LIBRARY_ATTRS = dicts.add(DEFAULT_ATTRS, {
    "aggregate": attr.string(
        doc = """Sets the aggregation mode for compiled outputs in `ll_library`.

        `"static"` invokes the archiver and creates an archive with a `.a`
        extension.
        `"bitcode"` invokes the bitcode linker and creates a bitcode file with a
        `.bc` extension.
        `"none"` will not invoke any aggregator. Instead, loose object files
        will be output by the rule.

        Not used by `ll_binary`, but `ll_library` targets with
        `aggregate = "bitcode"` can be used as `deps` for `ll_binary`.
        """,
        default = "static",
        values = ["static", "bitcode", "none"],
    ),
    "bitcode_link_flags": attr.string_list(
        doc = """Additional flags for the bitcode linker.

        If `aggregate = "bitcode"`, these flags are passed to the bitcode
        linker. The default bitcode linker is `llvm-link`.
        """,
    ),
    "bitcode_libraries": attr.label_list(
        doc = """Bitcode libraries that should always be linked.

        Only used if `aggregate = "bitcode"`.
        """,
        allow_files = [".bc"],
    ),
    "transitive_defines": attr.string_list(
        doc = """Additional transitive defines for this target.

        These defines will be defined by all depending downstream targets.
        """,
    ),
    "transitive_hdrs": attr.label_list(
        doc = """Transitive headers for this target.

        Any transitive headers will be exported (copied) to the build directory.

        Transitive headers are available to depending downstream targets.
        """,
        allow_files = True,
    ),
    "transitive_includes": attr.string_list(
        doc = """Additional transitive include paths for this target.

        Includes in this attribute will be added to the compile command line
        arguments for all downstream targets.
        """,
    ),
})

BINARY_ATTRS = dicts.add(DEFAULT_ATTRS, {
    "proprietary": attr.bool(
        doc = """Setting this to True will disable static linking of glibc.

        This attribute will be removed as soon as `rules_ll` uses LLVM's `libc`.
        """,
        default = False,
    ),
    "libraries": attr.label_list(
        doc = """Additional libraries linked to the final executable.

        Adds these libraries to the command line arguments for the linker.
        """,
        allow_files = True,
    ),
    "link_flags": attr.string_list(
        doc = """Additional flags for the linker.

        For `ll_binary`:
        This is the place for adding library search paths and external link
        targets.

        Assuming you have a library `/some/path/libmylib.a` on your host system,
        you can make `mylib.a` available to the linker by passing
        `["-L/some/path", "-lmylib"]` to this attribute.

        Prefer using the `libraries` attribute for library files already present
        within the bazel build graph.
        """,
    ),
})
