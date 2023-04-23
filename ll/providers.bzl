"""# `//ll:providers.bzl`

Providers for the `ll_binary`, `ll_library` and `ll_compilation_database` rules.
"""

LlInfo = provider(
    doc = "The default provider returned by an `ll_*` target.",
    fields = {
        "exposed_angled_includes": "A `depset` of angled includes.",
        "exposed_defines": "A `depset` of defines.",
        "exposed_hdrs": "A `depset` of header files.",
        "exposed_includes": "A `depset` of includes.",
        "exposed_bmis": "A `depset` of `LlModuleInfo` providers.",
    },
)

LlCompilationDatabaseFragmentsInfo = provider(
    doc = "Stores compilation database fragments.",
    fields = {
        "cdfs": "A `depset` of compilation database fragments.",
    },
)

LlCompilationDatabaseInfo = provider(
    doc = "Provider for a compilation database.",
    fields = {
        "compilation_database": """A `compile_commands.json` file.

        This file stores the compilation database.
        """,
    },
)

LlModuleInfo = provider(
    doc = "Provider for a module.",
    fields = {
        "module_name": "The name of the module.",
        "bmi": "The precompiled module interface.",
    },
)
