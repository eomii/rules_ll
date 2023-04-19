<!-- vale alex.ProfanityUnlikely = NO -->
# Setup

This guide explains how to set up `rules_ll`. If you just plan on using the
`rules_cc` compatible remote execution setup you still need to follow this
guide.

<!-- markdownlint-disable code-block-style -->
??? "System requirements"

    `rules_ll` makes heavy use of upstream dependencies. Staying upstream
    sometimes means that backwards-incompatible changes make it into `rules_ll`
    faster than into other toolchains. Because of this `rules_ll` won't work on
    some older systems.

    Prerequisites:

    - An `x86_64` processor. You can verify this with `uname -a`.
    - A Linux kernel with 64-bit support. You can verify this with
      `getconf LONG_BIT`.
    - As a rough guideline, at least 10 GB of disk space for fetched
      dependencies and build artifacts. Using all toolchains, debug and
      optimization modes might require more than 30 GB of disk space. If the
      build cache gets too large over time you can reset it using the
      `bazel clean` and `bazel clean --expunge` commands.
    - As a rough guideline, at least 1 GB of Memory per CPU core. The `nproc`
      command prints the number of CPU cores for your system.
<!-- markdownlint-enable code-block-style -->

1. Install the [nix package manager](https://nixos.org/download.html) and enable
   [flakes](https://nixos.wiki/wiki/Flakes).

2. Create a `rules_ll` compatible workspace. To keep the development shell in
   sync with the `rules_ll` Bazel module, pin the flake to a specific version:

    ```bash
    git init
    nix flake init -t github:eomii/rules_ll/<version>
    ```

    The default toolchains include C++ and HIP for AMDGPU. If you also want to
    target NVPTX devices (Nvidia GPUs), make sure to read the [CUDA license](https://docs.nvidia.com/cuda/eula/index.html)
    and set `unfree = true` in `flake.nix`.

    See [tags](https://github.com/eomii/rules_ll/tags) to find the most recent
    version.

3. Enter a `rules_ll` development shell:

    ```bash
    nix develop
    ```

4. Consider setting up at least a local remote cache as described in the [remote
   execution guide](./remote_execution.md).

See [`rules_ll/examples`](https://github.com/eomii/rules_ll/tree/main/examples)
for examples. The [Guides](https://ll.eomii.org/guides) explain more advanced
features of `rules_ll` such as Clang-Tidy, C++ modules, and heterogeneous
programming.
