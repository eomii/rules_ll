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
            #define HIP_VERSION_MINOR 5
            #define HIP_VERSION_PATCH 0
            #define HIP_VERSION 50500000
            #define HIP_VERSION_GITHASH "0000"
            #define HIP_VERSION_BUILD_NAME "rules_hip_custom_build_name_string"
            #define HIP_VERSION_BUILD_ID 0
            "
            >> include/hip/hip_version.h""",
        ],
        sha256 = "175dba35816f1db4bd4d7d483889e2fb42cf20a3375f07ad7e3773230f4e9367",
        strip_prefix = "HIP-930469a176d7a005074e201102dc90b038107593",
        urls = [
            "https://github.com/ROCm-Developer-Tools/HIP/archive/930469a176d7a005074e201102dc90b038107593.zip",
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
        sha256 = "5f6d3a1612e7af78951bf6e6635fba909615a8625194eaec1cbffed8df5a4168",
        strip_prefix = "ROCR-Runtime-a0d5e18e7752563daf4da970eae5ac8b6056a4c0",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCR-Runtime/archive/a0d5e18e7752563daf4da970eae5ac8b6056a4c0.zip",
        ],
        patches = [
            "@rules_ll//patches:rocr-amd_trap_handler_v2.diff",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "comgr",
        build_file = "@rules_ll//third-party-overlays:comgr.BUILD.bazel",
        sha256 = "68f8e4d506f79c7f2c9954a548b846f4c0c1e5c57b0d3c622d0f7f0b132e9276",
        strip_prefix = "ROCm-CompilerSupport-4abec2fb4cd33c2ec53510133f136b88b40b46aa",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-CompilerSupport/archive/4abec2fb4cd33c2ec53510133f136b88b40b46aa.zip",
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
        sha256 = "3a4682bc23a65707a52ec9945e6a4df1a24490756315106349793238ce691b7e",
        strip_prefix = "ROCm-Device-Libs-3e652abd2d3e63df1c92366a6c39af48e76f79b3",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-Device-Libs/archive/3e652abd2d3e63df1c92366a6c39af48e76f79b3.zip",
        ],
    )

rules_ll_dependencies = module_extension(
    implementation = _initialize_rules_ll_impl,
)
