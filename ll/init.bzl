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
        build_file = "@rules_ll//third-party-overlays:hip.BUILD.bazel",
        patch_cmds = [
            """echo "
            #define HIP_VERSION_MAJOR 5
            #define HIP_VERSION_MINOR 4
            #define HIP_VERSION_PATCH 3
            #define HIP_VERSION 50303000
            #define HIP_VERSION_GITHASH "0000"
            #define HIP_VERSION_BUILD_NAME "rules_hip_custom_build_name_string"
            #define HIP_VERSION_BUILD_ID 0
            "
            >> include/hip/hip_version.h""",
        ],
        sha256 = "23e51d3af517cd63019f8d199e46b84d5a18251d148e727f3985e8d99ccb0e58",
        strip_prefix = "HIP-rocm-5.4.3",
        urls = [
            "https://github.com/ROCm-Developer-Tools/HIP/archive/refs/tags/rocm-5.4.3.tar.gz",
        ],
    )

    http_archive(
        name = "hipamd",
        build_file = "@rules_ll//third-party-overlays:hipamd.BUILD.bazel",
        sha256 = "45e6ebb772ac8e5f2015420b106a755bd921c38a92f5a3121a2c9b22c98bb8ba",
        strip_prefix = "hipamd-rocm-5.4.3",
        urls = [
            "https://github.com/ROCm-Developer-Tools/hipamd/archive/refs/tags/rocm-5.4.3.zip",
        ],
        patches = [
            "@rules_ll//patches:hipamd_deprecate_fix.diff",
        ],
        patch_args = ["-p1"],
    )

rules_ll_dependencies = module_extension(
    implementation = _initialize_rules_ll_impl,
)
