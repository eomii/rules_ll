CLANG_TIDY_BUILD_FILE = """load(
    "@rules_ll//ll:defs.bzl",
    "ll_library",
    "ll_binary",
)

ll_library(
    name = "bugprone",
    srcs = glob(["bugprone/*.cpp"]),
    hdrs = glob(["bugprone/*.h", "*.h"]),
)

ll_library(
    name = "cppcoreguidelines",
    srcs = glob(["cppcoreguidelines/*.cpp"]),
    hdrs = glob(["cppcoreguidelines/*.h", "*.h"]),
)

ll_library(
    name = "google",
    srcs = glob(["google/*.cpp"]),
    hdrs = glob(["google/*.h", "*.h"]),
)

ll_library(
    name = "misc",
    srcs = glob(["misc/*.cpp"]),
    hdrs = glob(["misc/*.h", "*.h"]),
)

ll_library(
    name = "modernize",
    srcs = glob(["modernize/*.cpp"]),
    hdrs = glob(["modernize/*.h", "*.h"]),
)

ll_library(
    name = "performance",
    srcs = glob(["performance/*.cpp"]),
    hdrs = glob(["performance/*.h", "*.h"]),
)

ll_library(
    name = "portability",
    srcs = glob(["portability/*.cpp"]),
    hdrs = glob(["portability/*.h", "*.h"]),
)

ll_library(
    name = "readability",
    srcs = glob(["readability/*.cpp"]),
    hdrs = glob(["readability/*.h", "*.h"]),
)

ll_library(
    name = "lex",
    srcs = ["@llvm-project//clang:lib/Lex/HeaderMap.cpp"],
    # hdrs = ["@llvm-project//clang:lib/Lex/HeaderMap.h"])
)

ll_binary(
    name = "clang-tidy",
    srcs = [
        "ClangTidy.cpp",
        "ClangTidyCheck.cpp",
        "ClangTidyModule.cpp",
        "ClangTidyDiagnosticConsumer.cpp",
        "ClangTidyOptions.cpp",
        "ClangTidyProfiling.cpp",
        "ExpandModularHeadersPPCallbacks.cpp",
        "GlobList.cpp",
        "NoLintDirectiveHandler.cpp",
    ],
    hdrs = glob(["*.h"]),
    deps = [
        ":bugprone",
        ":cppcoreguidelines",
        ":google",
        ":misc",
        ":modernize",
        ":performance",
        ":portability",
        ":readability",
    ],
)"""
