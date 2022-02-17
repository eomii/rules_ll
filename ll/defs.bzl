"""# `//ll:defs.bzl`

These are the rules that should be imported in `BUILD.bazel` files.

To load e.g. the `ll_binary` rule:

```python
load("@rules_ll//ll:defs.bzl", "ll_binary")
```
"""

load(
    "//ll:ll.bzl",
    _ll_binary = "ll_binary",
    _ll_library = "ll_library",
)
load(
    "//ll:bootstrap_library.bzl",
    _ll_bootstrap_library = "ll_bootstrap_library",
)
load(
    "//ll:compilation_database.bzl",
    _ll_compilation_database = "ll_compilation_database",
)

ll_library = _ll_library
ll_binary = _ll_binary

ll_bootstrap_library = _ll_bootstrap_library

ll_compilation_database = _ll_compilation_database
