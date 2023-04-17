# Copyright 2016 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This becomes the BUILD file for @local_config_cc// under non-BSD unixes.

load(":cc_toolchain_config.bzl", "cc_toolchain_config")
load(":armeabi_cc_toolchain_config.bzl", "armeabi_cc_toolchain_config")
load("@rules_cc//cc:defs.bzl", "cc_toolchain", "cc_toolchain_suite")

package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

cc_library(
    name = "malloc",
)

filegroup(
    name = "empty",
    srcs = [],
)

filegroup(
    name = "cc_wrapper",
    srcs = ["cc_wrapper.sh"],
)

filegroup(
    name = "compiler_deps",
    srcs = glob(
        ["extra_tools/**"],
        allow_empty = True,
    ) + [":builtin_include_directory_paths"],
)

# This is the entry point for --crosstool_top.  Toolchains are found
# by lopping off the name of --crosstool_top and searching for
# the "${CPU}" entry in the toolchains attribute.
cc_toolchain_suite(
    name = "toolchain",
    toolchains = {
        "k8|clang": ":cc-compiler-k8",
        "k8": ":cc-compiler-k8",
        "armeabi-v7a|compiler": ":cc-compiler-armeabi-v7a",
        "armeabi-v7a": ":cc-compiler-armeabi-v7a",
    },
)

cc_toolchain(
    name = "cc-compiler-k8",
    all_files = ":compiler_deps",
    ar_files = ":compiler_deps",
    as_files = ":compiler_deps",
    compiler_files = ":compiler_deps",
    dwp_files = ":empty",
    linker_files = ":compiler_deps",
    module_map = ":module.modulemap",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
    toolchain_config = ":local",
    toolchain_identifier = "local",
)

cc_toolchain_config(
    name = "local",
    abi_libc_version = "glibc_2.35",
    abi_version = "local",
    compile_flags = [
        "-fstack-protector",
        "-Wall",
        "-Wthread-safety",
        "-Wself-assign",
        "-Wunused-but-set-parameter",
        "-Wno-free-nonheap-object",
        "-fcolor-diagnostics",
        "-fno-omit-frame-pointer",
    ],
    compiler = "clang",
    coverage_compile_flags = ["--coverage"],
    coverage_link_flags = ["--coverage"],
    cpu = "k8",
    cxx_builtin_include_directories = [
        "/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/resource-root/include",
        "/nix/store/wb2dlc8kpvrn960vq7j7c8822pi43n48-glibc-2.37-8-dev/include",
        "/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/resource-root/share",
        "/nix/store/2p592545ir2j7glhfxf0vl100xfp1sv6-libcxx-15.0.7-dev/include/c++/v1",
    ],
    cxx_flags = [
        "-std=c++17",
        "-O3",
        "-nostdinc++",
        "-nostdlib++",
        "-isystem/nix/store/2p592545ir2j7glhfxf0vl100xfp1sv6-libcxx-15.0.7-dev/include/c++/v1",
    ],
    dbg_compile_flags = ["-g"],
    host_system_name = "x86_64-unknown-linux-gnu",
    link_flags = [
        "-fuse-ld=/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/bin/ld.gold",
        "-Wl,-no-as-needed",
        "-Wl,-z,relro,-z,now",
        "-B/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/bin",
        "-L/nix/store/av4s15kfz46r1na0xgckigb9bxcjns29-libcxx-15.0.7/lib",
        "-L/nix/store/83qarbxw1hvhy2031nvx32iysjj3q4h9-libcxxabi-15.0.7/lib",
        "-lc++",
        "-Wl,-rpath,/nix/store/av4s15kfz46r1na0xgckigb9bxcjns29-libcxx-15.0.7/lib,-rpath,/nix/store/83qarbxw1hvhy2031nvx32iysjj3q4h9-libcxxabi-15.0.7/lib,-rpath,/nix/store/1n2l5law9g3b77hcfyp50vrhhssbrj5g-glibc-2.37-8/lib",
    ],
    link_libs = [
        "-lstdc++",
        "-lm",
    ],
    opt_compile_flags = [
        "-g0",
        "-O2",
        "-D_FORTIFY_SOURCE=1",
        "-DNDEBUG",
        "-ffunction-sections",
        "-fdata-sections",
    ],
    opt_link_flags = ["-Wl,--gc-sections"],
    supports_start_end_lib = True,
    target_libc = "glibc_2.35",
    target_system_name = "local",
    tool_paths = {
        "ar": "/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/bin/ar",
        "ld": "/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/bin/ld",
        "llvm-cov": "/nix/store/pbkhlqx5p5fd5h2fv6wa11j61ydx6mbf-llvm-15.0.7/bin/llvm-cov",
        "llvm-profdata": "/nix/store/pbkhlqx5p5fd5h2fv6wa11j61ydx6mbf-llvm-15.0.7/bin/llvm-profdata",
        "cpp": "/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/bin/cpp",
        "gcc": "/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/bin/clang",
        "dwp": "/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/bin/dwp",
        "gcov": "None",
        "nm": "/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/bin/nm",
        "objcopy": "/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/bin/objcopy",
        "objdump": "/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/bin/objdump",
        "strip": "/nix/store/h9yd7wdhscrmg0iqhn4y7s2mcc5qj96m-clang-wrapper-15.0.7/bin/strip",
    },
    toolchain_identifier = "local",
    unfiltered_compile_flags = [
        "-no-canonical-prefixes",
        "-Wno-builtin-macro-redefined",
        "-D__DATE__=\"redacted\"",
        "-D__TIMESTAMP__=\"redacted\"",
        "-D__TIME__=\"redacted\"",
    ],
)

# Android tooling requires a default toolchain for the armeabi-v7a cpu.
cc_toolchain(
    name = "cc-compiler-armeabi-v7a",
    all_files = ":empty",
    ar_files = ":empty",
    as_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
    toolchain_config = ":stub_armeabi-v7a",
    toolchain_identifier = "stub_armeabi-v7a",
)

armeabi_cc_toolchain_config(name = "stub_armeabi-v7a")
