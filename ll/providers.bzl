LlInfo = provider(
    doc = "Provider returned by ll targets.",
    fields = {
        "exported_headers": "A directory containing exported header files.",
        "transitive_headers": "A depset containing header files. These header files are carried to all depending targets.",
        "libraries": "A depset containing object files.",
        "transitive_defines": "A depset containing defines. These defines are carried to all depending targets.",
        "transitive_includes": "A depset containing include paths. These include paths are carried to all depending targets.",
    },
)
