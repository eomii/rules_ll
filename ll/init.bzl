load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# The current default commit for the LLVM repo. This should be updated
# frequently.
LLVM_COMMIT = "e7d65fca7ec470469ad3f8e7689b5e563346e4d7"
LLVM_SHA256 = "6a7bd0862b27d0d9b5b1c77b1c765dea32a5d9be9f01a8cc53a909e50555ff27"

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
        # Overlay the existing overlay at utils/bazel/llvm-project-overlay with
        # the files in rules_ll/llvm-bazel-overlay.
        #
        # If a BUILD.bazel file is already present in the original
        # llvm-project-overlay, we append the contents of the BUILD.bazel file
        # in the rules_ll overlay to the existing file. This way we don't break
        # the existing overlay while still being able to add targets to the
        # original BUILD.bazel files.
        patch_cmds = ["""
        for file in $(find ../rules_ll/llvm-project-overlay -type f); do
            if [ ! -d utils/bazel/${file:12} ]
                then mkdir -p `dirname utils/bazel/${file:12}`
            fi;
            cat $file >> utils/bazel/${file:12};
        done"""],
        patches = [
            "@rules_ll//patches:compiler-rt_float128_patch.diff",
        ],
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
