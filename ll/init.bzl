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
        sha256 = "7886ff1d74175b9e515b8bffc8dbee117c9afe3317430a37a90caa95bbf2c847",
        strip_prefix = "ROCm-Device-Libs-a6ae775cb7ffd63e4f74e208899e4acb4c24d76b",
        urls = [
            "https://github.com/RadeonOpenCompute/ROCm-Device-Libs/archive/a6ae775cb7ffd63e4f74e208899e4acb4c24d76b.zip",
        ],
    )

rules_ll_dependencies = module_extension(
    implementation = _initialize_rules_ll_impl,
)
