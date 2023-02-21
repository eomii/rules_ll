"""# `//ll:defs.bzl`

Import these rules in your `BUILD.bazel` files.

To load for example the `ll_binary` rule:

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
load(
    "//ll:coverage.bzl",
    _ll_coverage_test = "ll_coverage_test",
)

ll_library = _ll_library
ll_binary = _ll_binary
ll_compilation_database = _ll_compilation_database
ll_coverage_test = _ll_coverage_test

OFFLOAD_ALL_NVPTX = [
    "--offload-arch=sm_50,sm_52,sm_60,sm_61,sm_62,sm_70,sm_75,sm_80,sm_86,sm_87,sm_89,sm_89",
]
