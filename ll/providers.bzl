"""# `//ll:providers.bzl`

Providers used by `rules_ll`.
"""

LlInfo = provider(
    doc = "Provider returned by ll targets.",
    fields = {
        "exposed_angled_includes": "A depset containing angled include paths.",
        "exposed_defines": "A depset containing defines.",
        "exposed_hdrs": "A depset containing header files.",
        "exposed_includes": "A depset containing include paths.",
        "exposed_bmis": "A depset containing precompiled module interfaces.",
    },
)

LlCompilationDatabaseFragmentsInfo = provider(
    doc = "Provider containing compilation database fragments.",
    fields = {
        "cdfs": """A depset containing compilation database fragments.

        Assembling the compilation database fragments into a
        `compile_commands.json` file produces a compilation database for tools
        like clang-tidy.
        """,
    },
)

LlCompilationDatabaseInfo = provider(
    fields = {
        "compilation_database": """A compile_commands.json file containing a
        compilation database.
        """,
    },
)
