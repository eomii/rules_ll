LIBUNWIND_BUILD_FILE = """load("@rules_ll//ll:defs.bzl", "ll_bootstrap_library")

# The target below is required for the lld overlay which is not part of rules_ll.

# The ld64 linker and lld-macho use the libunwind headers only for the constant
# definitions, in order to parse and convert DWARF to the compact encoding.
cc_library(
    name = "unwind_headers_only",
    hdrs = [
        "include/__libunwind_config.h",
        "include/libunwind.h",
        "include/mach-o/compact_unwind_encoding.h",
    ],
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "libunwind_headers",
    srcs = glob(["include/**"]),
    visibility = ["//visibility:public"],
)

ll_bootstrap_library(
    name = "libll_unwind",
    deps = [
        "//libunwind/src:src",
    ],
    visibility = ["//visibility:public"],
)"""

LIBUNWIND_SRC_BUILD_FILE = """load("@rules_ll//ll:defs.bzl", "ll_bootstrap_library")

ll_bootstrap_library(
    name = "src",
    srcs = [
        "libunwind.cpp",
        "Unwind-EHABI.cpp",
        "Unwind-seh.cpp",

        "UnwindLevel1.c",
        "UnwindLevel1-gcc-ext.c",
        "Unwind-sjlj.c",

        "UnwindRegistersRestore.S",
        "UnwindRegistersSave.S",
    ],
    hdrs = [
        "AddressSpace.hpp",
        "assembly.h",
        "CompactUnwinder.hpp",
        "cet_unwind.h",
        "config.h",
        "dwarf2.h",
        "DwarfInstructions.hpp",
        "DwarfParser.hpp",
        "EHHeaderParser.hpp",
        "FrameHeaderCache.hpp",
        "libunwind_ext.h",
        "Registers.hpp",
        "RWMutex.hpp",
        "Unwind-EHABI.h",
        "UnwindCursor.hpp",

        "//libunwind:libunwind_headers",
        # ../include/libunwind.h
        # ../include/unwind.h
        # ../include/unwind_itanium.h
        # ../include/unwind_arm_ehabi.h
    ],
    compile_flags = [
        "-nostdinc++",
        "-nostdlib++",
        "-faligned-allocation",
        "-funwind-tables",
        "-fstrict-aliasing",
        "-fvisibility-inlines-hidden",
    ],
    deps = ["//compiler-rt:libll_compiler-rt"],
    visibility = ["//visibility:public"],
)"""
