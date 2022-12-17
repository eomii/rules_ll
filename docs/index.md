# `rules_ll`

An upstream Clang/LLVM-based Bazel toolchain for modern C++ and heterogeneous
programming.

## Features

- Upstream Clang/LLVM via the
  [`llvm-bazel-overlay`](https://github.com/llvm/llvm-project/tree/main/utils/bazel).
- Custom overlays for `libcxx`, `libcxxabi`, `libunwind`, `compiler-rt`,
  `openmp` and `clang-tidy`.
- Builtin `clang-tidy` invocations via an `ll_compilation_database` target.
- Support for sanitizers via target attributes.
- Toolchains for heterogeneous code targeting Nvidia GPUs with HIP or CUDA.
- C++ modules.
- Experimental OpenMP CPU support.

## Links

- [Discord Server](https://discord.gg/Ax67899n4y) (Qogecoin/rules_ll)
- [Quickstart](quickstart/quickstart.md)
- [Examples](https://github.com/eomii/rules_ll/tree/main/examples)
- [Guides](guides/index.md)

## Planned features

- OpenMP offloading for GPUs.
- HIP/AMD.
- SYCL.
- WebAssembly.
- Aarch64.
