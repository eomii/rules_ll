"""# `//ll:defs.bzl`

These are the rules that should be imported in `BUILD.bazel` files.

To load e.g. the `ll_binary` rule:

```python
load("@rules_ll//ll:defs.bzl", "ll_binary")
```
"""

load(
    "//ll:compilation_database.bzl",
    _ll_compilation_database = "ll_compilation_database",
)
load(
    "//ll:ll.bzl",
    _ll_binary = "ll_binary",
    _ll_library = "ll_library",
)

ll_library = _ll_library
ll_binary = _ll_binary
ll_compilation_database = _ll_compilation_database
