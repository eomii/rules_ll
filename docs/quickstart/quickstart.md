# Quickstart

This guide explains how to set up `rules_ll` in your project.

??? "System Requirements"

    `rules_ll` makes heavy use of upstream dependencies. Staying upstream
    sometimes means that backwards-incompatible changes make it into `rules_ll`
    faster than into other toolchains. Because of this `rules_ll` won't work on
    some older systems.

    Prerequisites:

    - An `x86_64` processor. You can verify this with `uname -a`.
    - A Linux kernel with 64-bit support. You can verify this with
      `getconf LONG_BIT`.
    - A `glibc` version that supports `mallinfo2`. Verify that `ldd --version`
      prints a value of at least `2.33`.
    - A functional host toolchain for C++. Some distributions have this by
      default, others require manual installation of a recent version of Clang
      or GCC. This toolchain compiles the upstream versions of Clang and
      clang-tidy used by `ll_*` targets.
    - For Nvidia GPU toolchains, a GPU with compute capability of at least
      `5.2`. This applies to 10xx series GPUs and up, and some `9xx` series
      GPUs. You can find a list of compute capabilities at <https://developer.nvidia.com/cuda-gpus>.
    - As a rough guideline, at least 10 GB of disk space for fetched
      dependencies and build artifacts. Using all toolchains, debug and
      optimization modes might require more than 30 GB of disk space. If the build
      cache gets too large over time you can reset it using the `bazel clean`
      and `bazel clean --expunge` commands.
    - As a rough guideline, at least 1 GB of Memory per CPU core. The `nproc`
      command prints the number of CPU cores for your system.

## Setup

Install [bazelisk](https://bazel.build/install/bazelisk).

If you don't plan on changing `rules_ll`, you don't need to clone its
repository. Instead, create these files to set up `rules_ll` in your project:

```python title="WORKSPACE.bazel"
# Empty, but must exist. We only use bzlmod.
```

```title=".bazelversion"
--8<-- ".bazelversion"
```

```python title="MODULE.bazel"
--8<-- "examples/MODULE.bazel::1"
```

```python title=".bazelrc"
--8<-- ".bazelrc"
```

You can now load the `ll_library` and `ll_binary` rule definitions in your
`BUILD.bazel` files like this:

```python
load("@rules_ll//ll:defs.bzl", "ll_library", "ll_binary")
```

See [`rules_ll/examples`](https://github.com/eomii/rules_ll/tree/main/examples)
for examples. The [Guides](https://ll.eomii.org/guides) explain more advanced
features of `rules_ll` such as Clang-Tidy, C++ modules, and heterogeneous
programming.
