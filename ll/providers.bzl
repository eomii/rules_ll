"""# `//ll:providers.bzl`

Providers used by `rules_ll`.
"""

LlInfo = provider(
    doc = "Provider returned by ll targets.",
    fields = {
        "transitive_hdrs": "A depset containing header files. These header files are carried to all depending targets.",
        "transitive_defines": "A depset containing defines. These defines are carried to all depending targets.",
        "transitive_includes": "A depset containing include paths. These include paths are carried to all depending targets.",
        "transitive_angled_includes": "A depset containing angled include paths. These include paths are carried to all depending targets.",
    },
)

LlCompilationDatabaseFragmentsInfo = provider(
    doc = "Provider containing command objects (compilation database fragments).",
    fields = {
        "cdfs": "A depset containing command database fragments. Assembling the command database fragments into a compile_commands.json file produces a compilation database for tools like clang-tidy.",
    },
)

LlCompilationDatabaseInfo = provider(
    fields = {
        "compilation_database": "A compile_commands.json file containing a compilation database.",
    },
)

LlToolchainConfigProvider = provider(
    fields = {
        "config": "A string indicating the toolchain configuration.",
    },
)
