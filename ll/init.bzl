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
            #define HIP_VERSION_MINOR 5
            #define HIP_VERSION_PATCH 0
            #define HIP_VERSION 50500000
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
            "@rules_ll//patches:hipamd_correct_jit_option.diff",
            "@rules_ll//patches:hipamd_inconsistent_overrides.diff",
            "@rules_ll//patches:hipamd_fix_extraneous_parentheses.diff",
            "@rules_ll//patches:hipamd_default_visibility.diff",
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
        sha256 = "e76989539fb2454cddb54221bcc81b37c0b429195142a106e592b3e812adc3d8",
        strip_prefix = "ROCm-CompilerSupport-5650602bbd8df037c0095d46f526e481b262c02c",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-CompilerSupport/archive/5650602bbd8df037c0095d46f526e481b262c02c.zip",
        ],
        patches = [
            "@rules_ll//patches:comgr_bc2h.diff",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "rocclr",
        build_file = "@rules_ll//third-party-overlays:rocclr.BUILD.bazel",
        sha256 = "7f49ffc6fd4183284e8ff2cf8b0e4897732979803ce3d1aec3780fae6ff0d482",
        strip_prefix = "ROCclr-20dfaee8767f7bc9df722fdbc397d77eed267607",
        urls = [
            "https://github.com/ROCm-Developer-Tools/ROCclr/archive/20dfaee8767f7bc9df722fdbc397d77eed267607.zip",
        ],
    )

    http_archive(
        name = "rocm-opencl-runtime",
        build_file = "@rules_ll//third-party-overlays:rocm-opencl-runtime.BUILD.bazel",
        sha256 = "6094046eb40a05b05075278c262a6c6f332f2a98a132eee969aab8e44d6154c5",
        strip_prefix = "ROCm-OpenCL-Runtime-f0c977ffb687e861a30d4de8082a1a468c3ce49f",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-OpenCL-Runtime/archive/f0c977ffb687e861a30d4de8082a1a468c3ce49f.zip",
        ],
    )

    http_archive(
        name = "rocm-device-libs",
        build_file = "@rules_ll//third-party-overlays:rocm-device-libs.BUILD.bazel",
        sha256 = "7886ff1d74175b9e515b8bffc8dbee117c9afe3317430a37a90caa95bbf2c847",
        strip_prefix = "ROCm-Device-Libs-a6ae775cb7ffd63e4f74e208899e4acb4c24d76b",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-Device-Libs/archive/a6ae775cb7ffd63e4f74e208899e4acb4c24d76b.zip",
        ],
    )

rules_ll_dependencies = module_extension(
    implementation = _initialize_rules_ll_impl,
)
