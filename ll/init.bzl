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
        name = "local-remote-execution",
        urls = [
            "https://github.com/TraceMachina/nativelink/archive/481226be52a84ad5a6b990cc48e9f97512d8ccd2.zip",
        ],
        integrity = "sha256-W65Ai9H1iuinfTVga/hvZegQGbSeLzqyEmrWXNOHpwE=",
        # Note: Keep this in sync with `flake.nix` and `devtools/up.sh`.
        strip_prefix = "nativelink-481226be52a84ad5a6b990cc48e9f97512d8ccd2/local-remote-execution",
    )

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
        integrity = "sha256-MnMFzzUdJyRakujoAUiGHI4U7HC2hl/LNF+za1q3tEw=",
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
        strip_prefix = "ROCR-Runtime-rocm-6.1.0",
        integrity = "sha256-ZPaRQTFkzI/+++tcLIgYmN8Zg/jOwqkzUBIpPy0uDiY=",
        urls = [
            "https://github.com/ROCm/ROCR-Runtime/archive/refs/tags/rocm-6.1.0.zip",
        ],
        patches = [
            "@rules_ll//patches:rocr-generated-files.diff",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "clr",
        build_file = "@rules_ll//third-party-overlays:clr.BUILD.bazel",
        integrity = "sha256-IKlxPbTNaoGdJSrQ/wv1d+iFeaE6Qomhcx/GOTKHQR0=",
        strip_prefix = "clr-rocm-5.7.1",
        urls = [
            "https://github.com/ROCm/clr/archive/refs/tags/rocm-5.7.1.zip",
        ],
        patches = [
            "@rules_ll//patches:hipamd_deprecate_fix.diff",
            "@rules_ll//patches:hipamd_correct_jit_option.diff",
            "@rules_ll//patches:hipamd_fix_extraneous_parentheses.diff",
            "@rules_ll//patches:hipamd_enforce_semicolon.diff",
            "@rules_ll//patches:hipamd_fix_local_address_space.diff",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "llvm-project-rocm",
        build_file = "@rules_ll//third-party-overlays:llvm-project-rocm.BUILD.bazel",
        strip_prefix = "llvm-project-e156b4cbbe9ec271c29b76979a4c04e59eb24c23",
        integrity = "sha256-OtN36Kg+aHJ4SJndw/AEd4qAz1WpCCsXp1v3mtePmhA=",
        urls = [
            "https://github.com/ROCm/llvm-project/archive/e156b4cbbe9ec271c29b76979a4c04e59eb24c23.zip",
        ],
        patches = [
            "@rules_ll//patches:comgr_bc2h.diff",
        ],
        patch_args = ["-p1"],
    )

rules_ll_dependencies = module_extension(
    implementation = _initialize_rules_ll_impl,
)
