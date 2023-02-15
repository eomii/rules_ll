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
        name = "hip",
        build_file = Label("@rules_ll//third-party-overlays:hip.BUILD.bazel"),
        patch_cmds = [
            """echo "
            #define HIP_VERSION_MAJOR 5
            #define HIP_VERSION_MINOR 3
            #define HIP_VERSION_PATCH 3
            #define HIP_VERSION 50303000
            #define HIP_VERSION_GITHASH "0000"
            #define HIP_VERSION_BUILD_NAME "rules_hip_custom_build_name_string"
            #define HIP_VERSION_BUILD_ID 0
            "
            >> include/hip/hip_version.h""",
        ],
        sha256 = "51d4049dc37d261afb9e1270e60e112708ff06b470721ff21023e16e040e4403",
        strip_prefix = "HIP-rocm-5.3.3",
        urls = [
            "https://github.com/ROCm-Developer-Tools/HIP/archive/refs/tags/rocm-5.3.3.tar.gz",
        ],
    )

    http_archive(
        name = "hipamd",
        build_file = Label("@rules_ll//third-party-overlays:hipamd.BUILD.bazel"),
        sha256 = "4b62bd403284d4bf66b836cdf0292d445c1bc46538f84b3395740e304f41cec4",
        strip_prefix = "hipamd-rocm-5.3.3",
        urls = [
            "https://github.com/ROCm-Developer-Tools/hipamd/archive/refs/tags/rocm-5.3.3.zip",
        ],
        patches = [
            Label("@rules_ll//patches:hipamd_deprecate_fix.diff"),
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "cuda_cudart",
        urls = [
            "https://developer.download.nvidia.com/compute/cuda/redist/cuda_cudart/linux-x86_64/cuda_cudart-linux-x86_64-11.8.89-archive.tar.xz",
        ],
        strip_prefix = "cuda_cudart-linux-x86_64-11.8.89-archive",
        sha256 = "56129e0c42df03ecb50a7bb23fc3285fa39af1a818f8826b183cf793529098bb",
        build_file_content = CUDA_BUILD_FILE,
    )

    http_archive(
        name = "cuda_cupti",
        urls = [
            "https://developer.download.nvidia.com/compute/cuda/redist/cuda_cupti/linux-x86_64/cuda_cupti-linux-x86_64-11.8.87-archive.tar.xz",
        ],
        strip_prefix = "cuda_cupti-linux-x86_64-11.8.87-archive",
        sha256 = "b2ebc5672aa7b896b5986200d132933c37e72df6b0bf5ac25c9cb18c2c03057f",
        build_file_content = CUDA_BUILD_FILE,
    )

    http_archive(
        name = "cuda_nvcc",
        urls = [
            "https://developer.download.nvidia.com/compute/cuda/redist/cuda_nvcc/linux-x86_64/cuda_nvcc-linux-x86_64-11.8.89-archive.tar.xz",
        ],
        strip_prefix = "cuda_nvcc-linux-x86_64-11.8.89-archive",
        sha256 = "7ee8450dbcc16e9fe5d2a7b567d6dec220c5894a94ac6640459e06231e3b39a5",
        build_file_content = CUDA_BUILD_FILE,
    )

    http_archive(
        name = "cuda_nvprof",
        urls = [
            "https://developer.download.nvidia.com/compute/cuda/redist/cuda_nvprof/linux-x86_64/cuda_nvprof-linux-x86_64-11.8.87-archive.tar.xz",
        ],
        strip_prefix = "cuda_nvprof-linux-x86_64-11.8.87-archive",
        sha256 = "cc01bc16f11b3aca89539a750c458121a4390d7694842627ca0221cc0b537107",
        build_file_content = CUDA_BUILD_FILE,
    )

    http_archive(
        name = "cuda_profiler_api",
        urls = [
            "https://developer.download.nvidia.com/compute/cuda/redist/cuda_profiler_api/linux-x86_64/cuda_profiler_api-linux-x86_64-11.8.86-archive.tar.xz",
        ],
        strip_prefix = "cuda_profiler_api-linux-x86_64-11.8.86-archive",
        sha256 = "0845942ac7f6fac6081780c32e0d95c883c786638b54d5a8eda05fde8089d532",
        build_file_content = CUDA_BUILD_FILE,
    )

    http_archive(
        name = "libcurand",
        urls = [
            "https://developer.download.nvidia.com/compute/cuda/redist/libcurand/linux-x86_64/libcurand-linux-x86_64-10.3.0.86-archive.tar.xz",
        ],
        strip_prefix = "libcurand-linux-x86_64-10.3.0.86-archive",
        sha256 = "9d30be251c1a0463b52203f6514dac5062844c606d13e234d1386e80c83db279",
        build_file_content = CUDA_BUILD_FILE,
    )

rules_ll_dependencies = module_extension(
    implementation = _initialize_rules_ll_impl,
)
