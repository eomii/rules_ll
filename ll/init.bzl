"""# `//ll:init.bzl`

Initializer function which should be called in the `WORKSPACE.bazel` file.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

CUDA_BUILD_FILE = """
filegroup(
    name = "contents",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
"""

def _initialize_rules_ll_impl(_):
    http_archive(
        name = "zstd",
        build_file = "@llvm-raw//utils/bazel/third_party_build:zstd.BUILD",
        integrity = "sha256-nEOWzIKc+uMZpuJhUgLoKq1BNyBzSC/OKG+seGRtPuQ=",
        strip_prefix = "zstd-1.5.5",
        urls = [
            "https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-1.5.5.tar.gz",
        ],
    )

    http_archive(
        name = "zlib-ng",
        build_file = "@llvm-raw//utils/bazel/third_party_build:zlib-ng.BUILD",
        integrity = "sha256-42uzRsAEcqH5/yoKRkPlkKJUvmN52nzd2drrmn8pZzE=",
        strip_prefix = "zlib-ng-2.0.7",
        urls = [
            "https://github.com/zlib-ng/zlib-ng/archive/refs/tags/2.0.7.zip",
        ],
    )

    http_archive(
        name = "hip",
        build_file = "@rules_ll//third-party-overlays:hip.BUILD.bazel",
        patch_cmds = [
            """echo "
            #define HIP_VERSION_MAJOR 5
            #define HIP_VERSION_MINOR 7
            #define HIP_VERSION_PATCH 0
            #define HIP_VERSION 50700000
            #define HIP_VERSION_GITHASH "0000"
            #define HIP_VERSION_BUILD_NAME "rules_hip_custom_build_name_string"
            #define HIP_VERSION_BUILD_ID 0
            "
            >> include/hip/hip_version.h""",
        ],
        integrity = "sha256-MnMFzzUdJyRakujoAUiGHI4U7HC2hl/LNF+za1q3tEw=",
        strip_prefix = "HIP-rocm-5.7.1",
        urls = [
            "https://github.com/ROCm/HIP/archive/refs/tags/rocm-5.7.1.zip",
        ],
    )

    http_archive(
        name = "roct",
        build_file = "@rules_ll//third-party-overlays:roct.BUILD.bazel",
        strip_prefix = "ROCT-Thunk-Interface-rocm-6.1.0",
        integrity = "sha256-KlnkZj87Dx8Zr0EpS4iiTVMnO2CU+eVTeqbHcaeYhU4=",
        urls = [
            "https://github.com/ROCm/ROCT-Thunk-Interface/archive/refs/tags/rocm-6.1.0.zip",
        ],
        patches = [
            "@rules_ll//patches:roct_adjust_kfd_bin_dir.diff",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "rocr",
        build_file = "@rules_ll//third-party-overlays:rocr.BUILD.bazel",
        strip_prefix = "ROCR-Runtime-rocm-6.0.2",
        integrity = "sha256-2M7DZm6qN0xas1UNOFAhhP0dckQEQFbJaMzrjAfuBL4=",
        urls = [
            "https://github.com/ROCm/ROCR-Runtime/archive/refs/tags/rocm-6.0.2.zip",
        ],
        patches = [
            "@rules_ll//patches:rocr-generated-files.diff",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "comgr",
        build_file = "@rules_ll//third-party-overlays:comgr.BUILD.bazel",
        strip_prefix = "ROCm-CompilerSupport-8c0f3bc3e1ad6d6f693c066a9ab96e612f86e606",
        integrity = "sha256-uUqfGHJV3aV3uUNDwsjj4sG9Ds/47ksX6cs6DQgTgyQ=",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-CompilerSupport/archive/8c0f3bc3e1ad6d6f693c066a9ab96e612f86e606.zip",
        ],
        patches = [
            "@rules_ll//patches:comgr_bc2h.diff",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "clr",
        build_file = "@rules_ll//third-party-overlays:clr.BUILD.bazel",
        strip_prefix = "clr-6e86d29a582e28d40d6d8acd55b9f4c32e974e87",
        integrity = "sha256-pL0EV8AXK5NsLJGoyNJCEaUlOSmK/uy9qXwX6JHmd18=",
        urls = [
            "https://github.com/ROCm/clr/archive/6e86d29a582e28d40d6d8acd55b9f4c32e974e87.zip",
        ],
        patches = [
            "@rules_ll//patches:hipamd_deprecate_fix.diff",
            "@rules_ll//patches:hipamd_correct_jit_option.diff",
            "@rules_ll//patches:hipamd_inconsistent_overrides.diff",
            "@rules_ll//patches:hipamd_fix_extraneous_parentheses.diff",
            "@rules_ll//patches:hipamd_enforce_semicolon.diff",
            "@rules_ll//patches:hipamd_fix_local_address_space.diff",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "rocm-device-libs",
        build_file = "@rules_ll//third-party-overlays:rocm-device-libs.BUILD.bazel",
        integrity = "sha256-Q2GrctM0GQjAnWDlFeiQXVIBHWS1xtzP+k9OWtgqGMM=",
        strip_prefix = "ROCm-Device-Libs-rocm-6.0.2",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-Device-Libs/archive/refs/tags/rocm-6.0.2.zip",
        ],
    )

rules_ll_dependencies = module_extension(
    implementation = _initialize_rules_ll_impl,
)
