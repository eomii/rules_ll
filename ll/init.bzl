"""# `//ll:init.bzl`


Initializer function which should be called in the `WORKSPACE.bazel` file.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _ll_local_crt_impl(ctx):
    for filename in ["Scrt1.o", "crti.o", "crtn.o"]:
        ctx.symlink(paths.join(ctx.attr.path, filename), filename)

    ctx.file(
        "WORKSPACE.bazel",
        content = """# empty""",
    )

    ctx.file(
        "BUILD.bazel",
        content = """filegroup(
            name = "crt",
            srcs = [
                ":Scrt1.o",
                ":crti.o",
                ":crtn.o",
            ],
            visibility = ["//visibility:public"],
        )""",
    )

ll_local_crt = repository_rule(
    implementation = _ll_local_crt_impl,
    attrs = {
        "build_file_content": attr.string(),
        "path": attr.string(),
    },
)

def initialize_rules_ll(local_crt_path):
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
    ll_local_crt(
        name = "local_crt",
        path = local_crt_path,
    )

    http_archive(
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
        urls = [
            "https://github.com/ROCm-Developer-Tools/HIP/archive/1389236aef23440d8fa2ccf36abc3ccd52c88127.zip",
        ],
    )

    http_archive(
        name = "hipamd",
        build_file = "@rules_ll//third-party-overlays:hipamd.BUILD.bazel",
        sha256 = "656f336e5ed8705629af811dea83096849298ddf05664051b730d3f104b0e18d",
        strip_prefix = "hipamd-a97f7e4214c4111723d1476942106022d1186c70",
        urls = [
            "https://github.com/ROCm-Developer-Tools/hipamd/archive/a97f7e4214c4111723d1476942106022d1186c70.zip",
        ],
        patches = ["@rules_ll//patches:hipamd_return_fix.diff"],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "cuda_cudart",
        urls = [
            "https://developer.download.nvidia.com/compute/cuda/redist/cuda_cudart/linux-x86_64/cuda_cudart-linux-x86_64-11.7.60-archive.tar.xz",
        ],
        strip_prefix = "cuda_cudart-linux-x86_64-11.7.60-archive",
        sha256 = "1c079add60a107f6dd9e72a0cc9cde03eb9d833506f355c22b9177c47a977552",
        build_file = "@rules_ll//third-party-overlays:cuda_cudart.BUILD.bazel",
    )

    http_archive(
        name = "cuda_nvcc",
        urls = [
            "https://developer.download.nvidia.com/compute/cuda/redist/cuda_nvcc/linux-x86_64/cuda_nvcc-linux-x86_64-11.7.64-archive.tar.xz",
        ],
        strip_prefix = "cuda_nvcc-linux-x86_64-11.7.64-archive",
        sha256 = "7721fcfa3eb183ecb1d7fe138ce52d8238f0a6ecf1e9964cf8cfe5d8b7ec3c92",
        build_file = "@rules_ll//third-party-overlays:cuda_nvcc.BUILD.bazel",
    )

    http_archive(
        name = "cuda_nvprof",
        urls = [
            "https://developer.download.nvidia.com/compute/cuda/redist/cuda_nvprof/linux-x86_64/cuda_nvprof-linux-x86_64-11.7.50-archive.tar.xz",
        ],
        strip_prefix = "cuda_nvprof-linux-x86_64-11.7.50-archive",
        sha256 = "8222eebaf3fe6ca1e4df6fda09cbd58f11de6d5b80b5596dcf5c5c45ae246028",
        build_file = "@rules_ll//third-party-overlays:cuda_nvprof.BUILD.bazel",
    )

    http_archive(
        name = "libcurand",
        urls = [
            "https://developer.download.nvidia.com/compute/cuda/redist/libcurand/linux-x86_64/libcurand-linux-x86_64-10.2.10.50-archive.tar.xz",
        ],
        strip_prefix = "libcurand-linux-x86_64-10.2.10.50-archive",
        sha256 = "a05411f1775d5783800b71f6b43fae660e3baf900ae07efb853e615116ee479b",
        build_file = "@rules_ll//third-party-overlays:libcurand.BUILD.bazel",
    )

def _initialize_rules_ll_impl(module_ctx):
    for module in module_ctx.modules:
        local_crt_path = module.tags.configure[0].local_crt_path
    initialize_rules_ll(local_crt_path)

rules_ll_dependencies = module_extension(
    implementation = _initialize_rules_ll_impl,
    tag_classes = {
        "configure": tag_class(attrs = {"local_crt_path": attr.string()}),
    },
)
