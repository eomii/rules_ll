load(
    "//ll:ll.bzl",
    _ll_binary = "ll_binary",
    _ll_library = "ll_library",
)
load(
    "//ll:bootstrap_library.bzl",
    _ll_bootstrap_library = "ll_bootstrap_library",
)

ll_library = _ll_library
ll_binary = _ll_binary

ll_bootstrap_library = _ll_bootstrap_library
