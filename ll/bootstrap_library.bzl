"""# `//ll:bootstrap_library.bzl`

This rule is used by `rules_ll` to boostrap `compiler-rt`, `libcxx`,
`libcxxabi` and `libunwind`. Users should use `ll_library` instead.
"""

load("//ll:ll.bzl", _ll_bootstrap_library = "ll_bootstrap_library")

ll_bootstrap_library = _ll_bootstrap_library
