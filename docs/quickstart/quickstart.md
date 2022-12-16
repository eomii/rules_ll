# Quickstart

This guide will explain how to set up `rules_ll` in your project.

??? "System Requirements"

    `rules_ll` makes heavy use of upstream dependencies and experimental features
    to the point of sometimes using non-release CI artifacts of Bazel to get
    bugfixes faster. Staying upstream sometimes means that backwards-incompatible
    changes make it into `rules_ll` faster than into other toolchains.
    This means that the software-side system requirements for `rules_ll` tend to be
    comparatively high.

    Minimum system requirements:

    - An `x86_64` processor. You can check this via `uname -a`.
    - A Linux kernel with 64-bit support. You can check this via `getconf LONG_BIT`.
    - A `glibc` version that supports `mallinfo2`. This will be the case if
      `ldd --version` prints a value of at least ``2.33``.
    - A functional host toolchain for C++. Some distros have this by default,
      others require manual installation of a recent version of Clang or GCC. This
      toolchain will be used to compile the upstream versions of Clang and
      clang-tidy that are used to build `ll_*` targets.
    - For Nvidia GPU toolchains, a GPU with compute capability of at least `5.2`.
      This will be the case for 10xx series GPUs and up, as well as some `9xx`
      series GPUs. A full list of compute capabilities can be found at
      <https://developer.nvidia.com/cuda-gpus>.
    - As a rough guideline, at least 10GB of disk space for fetched dependencies
      and build artifacts. Using all toolchains, debug and optimization modes may
      increase this requirement to 30GB of disk space. If the build cache gets too
      large over time it can be reset using the `bazel clean`
      and `bazel clean --expunge` commands.
    - As a rough guideline, at least 1GB of Memory per CPU core. You can check the
      number of CPU cores via `nproc`.

# Setup

Install [bazelisk](https://bazel.build/install/bazelisk).

If you do not plan on modifying `rules_ll`, you do not need to clone its
repository. Instead, the following commands are enough to set up a `rules_ll`
workspace:

```bash
touch WORKSPACE.bazel .bazelrc
echo 7.0.0-pre.20221102.3 > .bazelversion
echo 'bazel_dep(name="rules_ll", version="20221212.0")' > MODULE.bazel
```

Copy the following lines into the just created `.bazelrc` file:

```python
# Upstream LLVM/Clang requires C++17. This will only configure rules_cc.
common --repo_env=BAZEL_CXXOPTS='-std=c++17:-O3'

# Separate the toolchain from regular code. This will put execution artifacts
# into bazel-out/ll_linux_exec_platform-opt-exec-<hash>.
common --experimental_platform_in_output_dir

# We require bzlmod.
common --experimental_enable_bzlmod

# Default to the BCR.
common --registry=https://raw.githubusercontent.com/bazelbuild/bazel-central-registry/main/

# Additional registry required by rules_ll.
common --registry=https://raw.githubusercontent.com/eomii/bazel-eomii-registry/main/

# We need temporarily unresolved symlinks for CUDA.
common --experimental_allow_unresolved_symlinks

# Encapsulate the build environment.
common --incompatible_strict_action_env
```

You can now load the `ll_library` and `ll_binary` rule definitions in your
`BUILD.bazel` files via

```python
load("@rules_ll//ll:defs.bzl", "ll_library", "ll_binary")
```

See [rules_ll/examples](https://github.com/eomii/rules_ll/tree/main/examples)
for examples and consider checking out the [Guides](https://ll.eomii.org/guides)
on features like Clang-Tidy invocations, C++ modules and heterogeneous
programming.
