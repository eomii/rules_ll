"""# `//ll:init.bzl`

Initializer function which should be called in the `WORKSPACE.bazel` file.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//ll:os.bzl", "library_path")

def _ll_local_library_path_impl(repository_ctx):
    repository_ctx.file(
        "WORKSPACE.bazel",
        content = """# empty""",
    )

    repository_ctx.symlink(
        library_path(repository_ctx),
        "library_path",
    )

    repository_ctx.file(
        "BUILD.bazel",
        content = """filegroup(
            name = "local_library_path",
            srcs = [
                ":library_path",
            ],
            visibility = ["//visibility:public"],
        )""",
    )

ll_local_library_path = repository_rule(
    implementation = _ll_local_library_path_impl,
    attrs = {
        "build_file_content": attr.string(),
        "path": attr.string(),
    },
)

def initialize_rules_ll(local_library_path):
    """Initializes rules_ll and its dependencies.

    Args:
        local_library_path: Either "autodetect" to autodetect this path for
            supported operating systems, or the path to the directory containing
            `Scrt1.o`, `crti.o`, `crtn.o` and other library files. This is
            usually either `/usr/lib64` or `/usr/lib/x86_64-linux-gnu`.
    """
    ll_local_library_path(
        name = "local_library_path",
        path = local_library_path,
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
        local_library_path = module.tags.configure[0].local_library_path
    initialize_rules_ll(local_library_path)

rules_ll_dependencies = module_extension(
    implementation = _initialize_rules_ll_impl,
    tag_classes = {
        "configure": tag_class(attrs = {"local_library_path": attr.string()}),
    },
)
