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
        sha256 = "b6ca016f0d28c53fb75bcf0e8e7bc2054411265be43ee048711913814505cf50",
        strip_prefix = "HIP-c629e630247c17dafb2bc5c85dad8770175e1d33",
        urls = [
            "https://github.com/ROCm-Developer-Tools/HIP/archive/c629e630247c17dafb2bc5c85dad8770175e1d33.zip",
        ],
    )

    http_archive(
        name = "hipamd",
        build_file = "@rules_ll//third-party-overlays:hipamd.BUILD.bazel",
        sha256 = "1fbe0252cd545bd88cfbe195f7c068a4e83741cb581b3170e5bc8864cebdd6f2",
        strip_prefix = "hipamd-312dff7b794337aa040be0691acc78e9f968a8d2",
        urls = [
            "https://github.com/ROCm-Developer-Tools/hipamd/archive/312dff7b794337aa040be0691acc78e9f968a8d2.zip",
        ],
        patches = [
            "@rules_ll//patches:hipamd_deprecate_fix.diff",
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

rules_ll_dependencies = module_extension(
    implementation = _initialize_rules_ll_impl,
)
