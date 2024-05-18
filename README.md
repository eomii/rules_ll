# `rules_ll`

[![OpenSSF Best Practices](https://bestpractices.coreinfrastructure.org/projects/6822/badge)](https://bestpractices.coreinfrastructure.org/projects/6822)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/eomii/rules_ll/badge)](https://securityscorecards.dev/viewer/?uri=github.com/eomii/rules_ll)

An upstream Clang/LLVM-based toolchain for contemporary C++ and heterogeneous
programming.

This project interleaves Nix and Bazel with opinionated Starlark rules for C++.

<!-- vale alex.ProfanityUnlikely = NO -->
Builds running within `rules_ll`-compatible workspaces achieve virtually perfect
cache hit rates across machines, using C++ toolchains often several major
versions ahead of most other remote execution setups.

The `ll_*` rules use a toolchain purpose-built around Clang/LLVM. You can't
combine `ll_*` and `cc_*` targets at the moment, but you can still build `cc_*`
projects in `rules_ll`-workspaces to leverage the remote execution setup and
share caches.

## ✨ Setup

<!-- markdownlint-disable MD029 -->

1. Install [nix with flakes](https://github.com/NixOS/experimental-nix-installer).

2. Create a `rules_ll` compatible workspace. To keep the development shell in
   sync with the `rules_ll` Bazel module, pin the flake to a specific commit:

   ```bash
   git init
   nix flake init -t github:eomii/rules_ll/<commit>
   ```

   The default toolchains include C++ and HIP for AMDGPU. If you also want to
   target NVPTX devices (Nvidia GPUs), make sure to read the [CUDA license](https://docs.nvidia.com/cuda/eula/index.html)
   and set `comment.allowUnfree` and `config.cudaSupport` in `flake.nix`.

> [!WARNING]
> Don't use the tags or releases from the GitHub repository. They were used in
> old versions of `rules_ll` and probably in a broken state. Use a pinned commit
> instead.

3. Enter the `rules_ll` development shell:

   ```bash
   nix develop
   ```

> [!TIP]
> Strongly consider setting up [`direnv`](https://github.com/direnv/direnv) so
> that you don't need to remember running `nix develop` to enter the flake and
> `exit` to exit it.

4. Consider setting up at least a local remote cache as described in the [remote
   execution guide](https://ll.eomii.org/setup/remote_execution).
<!-- vale alex.ProfanityUnlikely = YES -->

<!-- markdownlint-enable MD029 -->

## 🔗 Links

- [Docs](https://ll.eomii.org)
- [Guides](https://ll.eomii.org/guides)
- [Examples](https://github.com/eomii/rules_ll/tree/main/examples)
- [Discussions](https://github.com/eomii/rules_ll/discussions)

## 🚀 C++ modules

Use the `interfaces` and `exposed_interfaces` attributes to build C++ modules.
[C++ modules guide](https://ll.eomii.org/guides/modules).

```python
load(
    "@rules_ll//ll:defs.bzl",
    "ll_binary",
    "ll_library",
)

ll_library(
    name = "mymodule",
    srcs = ["mymodule_impl.cpp"],
    exposed_interfaces = {
        "mymodule_interface.cppm": "mymodule",
    },
    compile_flags = ["-std=c++20"],
)

ll_binary(
    name = "main",
    srcs = ["main.cpp"],
    deps = [":mymodule"],
)
```

## 🧹 Clang-tidy

Build compilation databases to use Clang-Tidy as part of your workflows and CI
pipelines. [Clang-Tidy guide](https://ll.eomii.org/guides/clang_tidy).

```python
load(
   "@rules_ll//ll:defs.bzl",
   "ll_compilation_database",
)

filegroup(
    name = "clang_tidy_config",
    srcs = [".clang-tidy"],
)

ll_compilation_database(
   name = "compile_commands",
   targets = [
      ":my_very_tidy_target",
   ],
   config = ":clang_tidy_config",
)
```

## 😷 Sanitizers

Integrate sanitizers in your builds with the `sanitize` attribute.
[Sanitizers guide](https://ll.eomii.org/guides/sanitizers).

```python
load(
    "@rules_ll//ll:defs.bzl",
    "ll_binary",
)

ll_binary(
    name = "sanitizer_example",
    srcs = ["totally_didnt_shoot_myself_in_the_foot.cpp"],
    sanitize = ["address"],
)
```

## 🧮 CUDA and HIP

Use CUDA and HIP without any manual setup. [CUDA and HIP guide](https://ll.eomii.org/guides/cuda_and_hip).

```python
load(
    "@rules_ll//ll:defs.bzl",
    "ll_binary",
)

ll_binary(
    name = "cuda_example",
    srcs = ["look_mum_no_cuda_setup.cu"],
    compilation_mode = "cuda_nvptx",  # Or "hip_nvptx". Or "hip_amdgpu".
    compile_flags = [
        "--std=c++20",
        "--offload-arch=sm_70",  # Your GPU model.
    ],
)
```

## 📜 License

Licensed under the Apache 2.0 License with LLVM exceptions.

This repository uses overlays and automated setups for the CUDA toolkit and HIP.
Using `compilation_mode` for heterogeneous toolchains implies acceptance of
their licenses.
