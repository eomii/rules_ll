load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load(
    "@rules_ll//libcxx:libcxx_overlay.bzl",
    "LIBCXX_BUILD_FILE",
    "LIBCXX_CONFIG_SITE",
    "LIBCXX_SRC_BUILD_FILE",
)
load(
    "@rules_ll//libcxxabi:libcxxabi_overlay.bzl",
    "LIBCXXABI_BUILD_FILE",
    "LIBCXXABI_SRC_BUILD_FILE",
)
load(
    "@rules_ll//compiler-rt:compiler-rt_overlay.bzl",
    "COMPILER_RT_BUILD_FILE",
    "COMPILER_RT_LIB_BUILD_FILE",
)
load(
    "@rules_ll//libunwind:libunwind_overlay.bzl",
    "LIBUNWIND_BUILD_FILE",
    "LIBUNWIND_SRC_BUILD_FILE",
)

# The current default commit for the LLVM repo. This should be updated
# frequently.
LLVM_COMMIT = "5372160a188e3e0e84d09ba6a8353e39daefe4a0"
LLVM_SHA256 = "8eaa0bf7e82eab770597397da00dce0474f839c902bfa09f66ccb9921ca49b2e"

def initialize_rules_ll(
        local_crt_path,
        llvm_commit = LLVM_COMMIT,
        llvm_sha256 = LLVM_SHA256):
    maybe(
        http_archive,
        name = "llvm-raw",
        build_file_content = "# empty",
        sha256 = llvm_sha256,
        strip_prefix = "llvm-project-" + llvm_commit,
        urls = ["https://github.com/llvm/llvm-project/archive/{}.tar.gz".format(llvm_commit)],
        patch_cmds = [
            # Libc++ overlay
            "mkdir utils/bazel/llvm-project-overlay/libcxx",
            "echo '{}' > libcxx/include/__config_site".format(LIBCXX_CONFIG_SITE),
            "echo '{}' > utils/bazel/llvm-project-overlay/libcxx/BUILD.bazel".format(LIBCXX_BUILD_FILE),
            "mkdir utils/bazel/llvm-project-overlay/libcxx/src",
            "echo '{}' > utils/bazel/llvm-project-overlay/libcxx/src/BUILD.bazel".format(LIBCXX_SRC_BUILD_FILE),

            # Libcxxabi overlay.
            "mkdir utils/bazel/llvm-project-overlay/libcxxabi",
            "echo '{}' > utils/bazel/llvm-project-overlay/libcxxabi/BUILD.bazel".format(LIBCXXABI_BUILD_FILE),
            "mkdir utils/bazel/llvm-project-overlay/libcxxabi/src",
            "echo '{}' > utils/bazel/llvm-project-overlay/libcxxabi/src/BUILD.bazel".format(LIBCXXABI_SRC_BUILD_FILE),

            # Libunwind overlay.
            # The libunwind directory already exists in the bazel overlay.
            "echo '{}' > utils/bazel/llvm-project-overlay/libunwind/BUILD.bazel".format(LIBUNWIND_BUILD_FILE),
            "mkdir utils/bazel/llvm-project-overlay/libunwind/src",
            "echo '{}' > utils/bazel/llvm-project-overlay/libunwind/src/BUILD.bazel".format(LIBUNWIND_SRC_BUILD_FILE),

            # Compiler-RT overlay. Under construction.
            "mkdir utils/bazel/llvm-project-overlay/compiler-rt",
            "echo '{}' > utils/bazel/llvm-project-overlay/compiler-rt/BUILD.bazel".format(COMPILER_RT_BUILD_FILE),
            "mkdir utils/bazel/llvm-project-overlay/compiler-rt/lib",
            "echo '{}' > utils/bazel/llvm-project-overlay/compiler-rt/lib/BUILD.bazel".format(COMPILER_RT_LIB_BUILD_FILE),
        ],
        patches = ["@rules_ll//compiler-rt:float128_patch.diff"],
        patch_args = ["-p1"],
    )

    maybe(
        native.new_local_repository,
        name = "local_crt",
        path = local_crt_path,
        build_file_content = """filegroup(
            name = "crt",
            srcs = [
                ":crt1.o",
                ":crti.o",
                ":crtn.o",
            ],
            visibility = ["//visibility:public"],
        )""",
    )
