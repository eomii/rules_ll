"""# `//ll:init.bzl`

Initializer function which should be called in the `WORKSPACE.bazel` file.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# The current default commit for the LLVM repo. This should be updated
# frequently.
LLVM_COMMIT = "df6c26fd3499d0770eff3922b90f576d7bde3880"
LLVM_SHA256 = "4bfa9f4444e54dfe338710f2c5729def357414d33eb5e044cc47fc4497a6b57b"

def initialize_rules_ll(
        local_crt_path,
        llvm_commit = LLVM_COMMIT,
        llvm_sha256 = LLVM_SHA256):
    """Initializes the LLVM repository.

    The correct `local_crt_path` is likely something like `/usr/lib64` or
    `/usr/x86_64-unknown-linux-gnu`.

    `rules_ll` modifies the existing bazel overlay in the LLVM repository. If
    the overlay in `rules_ll` breaks because you specified a custom commit, you
    can patch `rules_ll` during import e.g. via

    ```python
    http_archive(
        name = "rules_ll",
        sha256 = "<Correct SHA256>",
        urls = [
            "https://github.com/neqochan/rules_ll/archive/<COMMIT_HASH>.zip"
        ],
        patches = [":my_patch.diff"],
        patch_args = ["-p1"],
    )
    ```

    Args:
        local_crt_path: The path to the directory containing `crt1.o`, `crti.o`
            and `crtn.o`.
        llvm_commit: The llvm-commit to use for the `llvm-project` repository.
        llvm_sha256: The SHA256 for corresponding to `llvm_commit`. Bazel will
            print the correct value if this is set to `None`.
    """
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
            "@rules_ll//patches:clang_header_patch.diff",
            "@rules_ll//patches:mallinfo2_patch.diff",
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
