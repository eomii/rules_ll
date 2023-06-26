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
        sha256 = "9c4396cc829cfae319a6e2615202e82aad41372073482fce286fac78646d3ee4",
        strip_prefix = "zstd-1.5.5",
        urls = [
            "https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-1.5.5.tar.gz",
        ],
    )

    http_archive(
        name = "zlib-ng",
        build_file = "@llvm-raw//utils/bazel/third_party_build:zlib-ng.BUILD",
        sha256 = "e36bb346c00472a1f9ff2a0a4643e590a254be6379da7cddd9daeb9a7f296731",
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
        sha256 = "e7596b05a6b1b6eee45ee7b365f2f31bddaed4e02352e88d8f06a67ec56d37e9",
        strip_prefix = "HIP-d579c4d3cab15f7beb2943eddb75dba8877c2be3",
        urls = [
            "https://github.com/ROCm-Developer-Tools/HIP/archive/d579c4d3cab15f7beb2943eddb75dba8877c2be3.zip",
        ],
    )

    http_archive(
        name = "hipamd",
        build_file = "@rules_ll//third-party-overlays:hipamd.BUILD.bazel",
        sha256 = "f82a20574e47ef10d2cd9e4b3c5e0feed2fdc0a6142fec36ed6621b62f725d21",
        strip_prefix = "hipamd-4209792929ddf54ba9530813b7879cfdee42df14",
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
        sha256 = "0c305a57c97772ca973bcbc02dda6ab229c75c63ca5ae19e3c68a774ea18346f",
        strip_prefix = "ROCT-Thunk-Interface-rocm-5.4.3",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCT-Thunk-Interface/archive/refs/tags/rocm-5.4.3.zip",
        ],
        patches = [
            "@rules_ll//patches:roct_adjust_kfd_bin_dir.diff",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "rocr",
        build_file = "@rules_ll//third-party-overlays:rocr.BUILD.bazel",
        sha256 = "eef185bb551b6b68d51adf9557b0647578963688791efca727e89a5f60da1758",
        strip_prefix = "ROCR-Runtime-6fdf759273a098829dfd642fb730ea410f33b152",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCR-Runtime/archive/6fdf759273a098829dfd642fb730ea410f33b152.zip",
        ],
        patches = [
            "@rules_ll//patches:rocr-amd_trap_handler_v2.diff",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "comgr",
        build_file = "@rules_ll//third-party-overlays:comgr.BUILD.bazel",
        sha256 = "50f87b928a12241b56b2eecede5dec6c87758b9e64958f78023097d9aff4d839",
        strip_prefix = "ROCm-CompilerSupport-65abd4d61e2c15ecdf2c5ec802d98987f1dd427a",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-CompilerSupport/archive/65abd4d61e2c15ecdf2c5ec802d98987f1dd427a.zip",
        ],
        patches = [
            "@rules_ll//patches:comgr_bc2h.diff",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "rocclr",
        build_file = "@rules_ll//third-party-overlays:rocclr.BUILD.bazel",
        sha256 = "44b654d86a5459c783c0bfe663e257da110844f878e8dab67691c114d4d4655f",
        strip_prefix = "ROCclr-63540e0b08c508c440e5d50431cc3d80647a45c4",
        urls = [
            "https://github.com/ROCm-Developer-Tools/ROCclr/archive/63540e0b08c508c440e5d50431cc3d80647a45c4.zip",
        ],
    )

    http_archive(
        name = "rocm-opencl-runtime",
        build_file = "@rules_ll//third-party-overlays:rocm-opencl-runtime.BUILD.bazel",
        sha256 = "515c666be19fe6fc101b4bfb135c20d022a29cc6e6f55fe5453d949e39c27d3e",
        strip_prefix = "ROCm-OpenCL-Runtime-a919c67b5a581852ea1773b21e1e2109ba208274",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-OpenCL-Runtime/archive/a919c67b5a581852ea1773b21e1e2109ba208274.zip",
        ],
    )

    http_archive(
        name = "rocm-device-libs",
        build_file = "@rules_ll//third-party-overlays:rocm-device-libs.BUILD.bazel",
        sha256 = "c4b8bbeb208aa9d914fa4a40cf1b76e2752fd300c79fe897d84a16a4e1d51ba9",
        strip_prefix = "ROCm-Device-Libs-7fff8d33f591a24489222ee37560b0021f202316",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-Device-Libs/archive/7fff8d33f591a24489222ee37560b0021f202316.zip",
        ],
    )

rules_ll_dependencies = module_extension(
    implementation = _initialize_rules_ll_impl,
)
