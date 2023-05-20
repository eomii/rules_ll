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
    _ll_test = "ll_test",
)
load(
    "//ll:coverage.bzl",
    _ll_coverage_test = "ll_coverage_test",
)

ll_binary = _ll_binary
ll_library = _ll_library
ll_test = _ll_test
ll_compilation_database = _ll_compilation_database
ll_coverage_test = _ll_coverage_test

OFFLOAD_ALL_NVPTX = [
    "--offload-arch=sm_50,sm_52,sm_60,sm_61,sm_62,sm_70,sm_75,sm_80,sm_86,sm_87,sm_89,sm_89,sm_90",
]

OFFLOAD_ALL_AMDGPU = [
    "--offload-arch=gfx801,gfx802,gfx803,gfx805,gfx810,gfx900,gfx902,gfx904,gfx908,gfx909,gfx90a,gfx90c,gfx940,gfx941,gfx942,gfx1010,gfx1011,gfx1012,gfx1013,gfx1030,gfx1031,gfx1032,gfx1033,gfx1034,gfx1035,gfx1036,gfx1100,gfx1101,gfx1102,gfx1103",
]
