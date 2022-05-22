"""# `//ll:init.bzl`

Initializer function which should be called in the `WORKSPACE.bazel` file.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# The current default commit for the LLVM repo. This should be updated
# frequently.
LLVM_COMMIT = "ffdbecccafdf96c37921e3e74bb436aa169faefa"
LLVM_SHA256 = "b603ffaf8e141f2be751810a0a7def7dfb1844fe95f64fb0cea7901ab3d5948b"

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

    maybe(
        http_archive,
        name = "hip",
        build_file = "@rules_ll//third-party-overlays:hip.BUILD.bazel",
        patch_cmds = [
            """echo "
            #define HIP_VERSION_MAJOR 5
            #define HIP_VERSION_MINOR 1
            #define HIP_VERSION_PATCH 0
            #define HIP_VERSION 50100000
            #define HIP_VERSION_GITHASH "1389236aef23440d8fa2ccf36abc3ccd52c88127"
            #define HIP_VERSION_BUILD_NAME "rules_hip_custom_build_name_string"
            #define HIP_VERSION_BUILD_ID 0
            "
            >> include/hip/hip_version.h""",
        ],
        sha256 = "2cefc5ea23fb6d7bdb1437133d8c95c01ddb1ce12c4a32ca5d24fe3a4236cb57",
        strip_prefix = "HIP-1389236aef23440d8fa2ccf36abc3ccd52c88127",
        urls = ["https://github.com/ROCm-Developer-Tools/HIP/archive/1389236aef23440d8fa2ccf36abc3ccd52c88127.zip"],
    )

    maybe(
        http_archive,
        name = "hipamd",
        build_file = "@rules_ll//third-party-overlays:hipamd.BUILD.bazel",
        sha256 = "656f336e5ed8705629af811dea83096849298ddf05664051b730d3f104b0e18d",
        strip_prefix = "hipamd-a97f7e4214c4111723d1476942106022d1186c70",
        urls = ["https://github.com/ROCm-Developer-Tools/hipamd/archive/a97f7e4214c4111723d1476942106022d1186c70.zip"],
        patches = ["@rules_ll//patches:hipamd_return_fix.diff"],
        patch_args = ["-p1"],
    )

    maybe(
        http_archive,
        name = "cuda_cudart",
        urls = ["https://developer.download.nvidia.com/compute/cuda/redist/cuda_cudart/linux-x86_64/cuda_cudart-linux-x86_64-11.6.55-archive.tar.xz"],
        strip_prefix = "cuda_cudart-linux-x86_64-11.6.55-archive",
        sha256 = "734a77b3a26a9d08489d43afb74bad230c7c4a0ed2d17a6317a47cf363dca521",
        # workspace_file_content = """workspace(name = "cuda_cudart")""",
        build_file = "@rules_ll//third-party-overlays:cuda_cudart.BUILD.bazel",
    )

    maybe(
        http_archive,
        name = "cuda_nvcc",
        urls = ["https://developer.download.nvidia.com/compute/cuda/redist/cuda_nvcc/linux-x86_64/cuda_nvcc-linux-x86_64-11.6.124-archive.tar.xz"],
        strip_prefix = "cuda_nvcc-linux-x86_64-11.6.124-archive",
        sha256 = "8c81199c5a096869a10c284197cefc1a958df8bf482322a0a48dff9cc82291b8",
        build_file = "@rules_ll//third-party-overlays:cuda_nvcc.BUILD.bazel",
    )

    maybe(
        http_archive,
        name = "cuda_nvprof",
        urls = ["https://developer.download.nvidia.com/compute/cuda/redist/cuda_nvprof/linux-x86_64/cuda_nvprof-linux-x86_64-11.6.124-archive.tar.xz"],
        strip_prefix = "cuda_nvprof-linux-x86_64-11.6.124-archive",
        sha256 = "2c05600562bcbe4841cd0d86fdbf2fecba36c54ad393979cb22653dd45487a9b",
        build_file = "@rules_ll//third-party-overlays:cuda_nvprof.BUILD.bazel",
    )

    maybe(
        http_archive,
        name = "libcurand",
        urls = ["https://developer.download.nvidia.com/compute/cuda/redist/libcurand/linux-x86_64/libcurand-linux-x86_64-10.2.9.124-archive.tar.xz"],
        strip_prefix = "libcurand-linux-x86_64-10.2.9.124-archive",
        sha256 = "87b1d70ec749db31cabb79ae5034b05883666e1848aa3feca643ea4a68dea47e",
        build_file = "@rules_ll//third-party-overlays:libcurand.BUILD.bazel",
    )
