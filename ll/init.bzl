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
            #define HIP_VERSION 50500000
            #define HIP_VERSION_GITHASH "0000"
            #define HIP_VERSION_BUILD_NAME "rules_hip_custom_build_name_string"
            #define HIP_VERSION_BUILD_ID 0
            "
            >> include/hip/hip_version.h""",
        ],
        integrity = "sha256-51lrBaaxtu7kXuezZfLzG92u1OAjUuiNjwamfsVtN+k=",
        strip_prefix = "HIP-d579c4d3cab15f7beb2943eddb75dba8877c2be3",
        urls = [
            "https://github.com/ROCm-Developer-Tools/HIP/archive/d579c4d3cab15f7beb2943eddb75dba8877c2be3.zip",
        ],
    )

    http_archive(
        name = "hipamd",
        build_file = "@rules_ll//third-party-overlays:hipamd.BUILD.bazel",
        strip_prefix = "hipamd-4209792929ddf54ba9530813b7879cfdee42df14",
        integrity = "sha256-+CogV05H7xDSzZ5LPF4P7tL9wKYUL+w27WYhti9yXSE=",
        urls = [
            "https://github.com/ROCm-Developer-Tools/hipamd/archive/4209792929ddf54ba9530813b7879cfdee42df14.zip",
        ],
        patches = [
            "@rules_ll//patches:hipamd_deprecate_fix.diff",
            "@rules_ll//patches:hipamd_correct_jit_option.diff",
            "@rules_ll//patches:hipamd_inconsistent_overrides.diff",
            "@rules_ll//patches:hipamd_fix_extraneous_parentheses.diff",
            "@rules_ll//patches:hipamd_default_visibility.diff",
            "@rules_ll//patches:hipamd_enforce_semicolon.diff",
            "@rules_ll//patches:hipamd_fix_local_address_space.diff",
        ],
        patch_args = ["-p1"],
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
        strip_prefix = "ROCR-Runtime-rocm-5.6.0",
        integrity = "sha256-wI3YXp94ZZlSv89eTtOkIfensan+B5wOZdPdx6GOaj4=",
        urls = [
            "https://github.com/ROCm/ROCR-Runtime/archive/refs/tags/rocm-5.6.0.zip",
        ],
        patches = [
            "@rules_ll//patches:rocr-amd_trap_handler_v2.diff",
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
        strip_prefix = "clr-899c0e54e780dbd25aac0071294f9daff829981b",
        integrity = "sha256-+67pyGhBBRUcYwOnlvLXtum04v/xxgq+HbnRZbNLCz4=",
        urls = [
            "https://github.com/ROCm/clr/archive/899c0e54e780dbd25aac0071294f9daff829981b.zip",
        ],
    )

    http_archive(
        name = "rocm-opencl-runtime",
        build_file = "@rules_ll//third-party-overlays:rocm-opencl-runtime.BUILD.bazel",
        integrity = "sha256-UVxma+Gf5vwQG0v7E1wg0CKinMbm9V/lRT2UnjnCfT4=",
        strip_prefix = "ROCm-OpenCL-Runtime-a919c67b5a581852ea1773b21e1e2109ba208274",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-OpenCL-Runtime/archive/a919c67b5a581852ea1773b21e1e2109ba208274.zip",
        ],
    )

    http_archive(
        name = "rocm-device-libs",
        build_file = "@rules_ll//third-party-overlays:rocm-device-libs.BUILD.bazel",
        integrity = "sha256-xLi76yCKqdkU+kpAzxt24nUv0wDHn+iX2EoWpOHVG6k=",
        strip_prefix = "ROCm-Device-Libs-7fff8d33f591a24489222ee37560b0021f202316",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-Device-Libs/archive/7fff8d33f591a24489222ee37560b0021f202316.zip",
        ],
    )

rules_ll_dependencies = module_extension(
    implementation = _initialize_rules_ll_impl,
)
