def clang_tidy_module(name, deps = []):
    """Wrapper around cc_library to shorten deps."""
    native.cc_library(
        name = name,
        srcs = native.glob([name + "/*.cpp"]),
        hdrs = native.glob([name + "/*.h", name + "/*.inc"]),
        deps = deps + [
            ":clang_tidy",
            ":clang_tidy_utils",
            "@llvm-project//clang:ast",
            "@llvm-project//clang:ast_matchers",
            "@llvm-project//clang:basic",
            "@llvm-project//clang:lex",
            "@llvm-project//llvm:FrontendOpenMP",
            "@llvm-project//llvm:Support",
        ],
        alwayslink = True,
    )
