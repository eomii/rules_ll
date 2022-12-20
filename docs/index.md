# `rules_ll`

An upstream Clang/LLVM-based Bazel toolchain for modern C++ and heterogeneous
programming.

## Features

- A toolchain that uses Clang/LLVM from the [`llvm-bazel-overlay`](https://github.com/llvm/llvm-project/tree/main/utils/bazel)
  and extends it with custom overlays.
- Clang-tidy to help you write your programs.
- Sanitizers to help you find subtle bugs.
- Toolchains to target Nvidia GPUs with HIP or CUDA.
- C++ module support to improve your compile times.
- Basic OpenMP CPU support.

## Links

- [Discord Server](https://discord.gg/Ax67899n4y)
- [Quickstart](quickstart/quickstart.md)
- [Examples](https://github.com/eomii/rules_ll/tree/main/examples)
- [Guides](guides/index.md)

## Planned features

- OpenMP for GPUs.
- HIP/AMD.
- SYCL.
- WebAssembly.
- Aarch64.
