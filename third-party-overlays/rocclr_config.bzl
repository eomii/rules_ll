"""# `//third-party-overlays:rocclr_config.bzl

Shared config for all targets depending on rocclr.
"""

ROCCLR_DEFINES = [
    # Our config. Same as the default CMake config.
    "ROCCLR_ENABLE_LC=1",
    "ROCCLR_ENABLE_HSA=1",

    # rules_ll only supports linux at the moment.
    "ATI_OS_LINUX",
    "LITTLEENDIAN_CPU",
    "WITH_LIQUID_FLASH=0",

    # We need comgr.
    "USE_COMGR_LIBRARY",

    # We ship numactl as part of the Nix environment.
    "ROCCLR_SUPPORT_NUMA_POLICY",

    # Enable the HSA device flag.
    "WITH_HSA_DEVICE",

    # Enable lightning compiler.
    "WITH_LIGHTNING_COMPILER",

    # OpenCL defines.
    "HAVE_CL2_HPP",
    "OPENCL_MAJOR=2",
    "OPENCL_MINOR=1",
    "OPENCL_C_MAJOR=2",
    "OPENCL_C_MINOR=0",
    "CL_TARGET_OPENCL_VERSION=220",
    "CL_USE_DEPRECATED_OPENCL_1_0_APIS",
    "CL_USE_DEPRECATED_OPENCL_1_1_APIS",
    "CL_USE_DEPRECATED_OPENCL_1_2_APIS",
    "CL_USE_DEPRECATED_OPENCL_2_0_APIS",
] + select({
    "@llvm-project-rocm//:shared": ["COMGR_DYN_DLL"],
    "//conditions:default": [],
})
