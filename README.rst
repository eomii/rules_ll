An Upstream LLVM/Clang Toolchain for Bazel
------------------------------------------

This repository exposes ``ll_library`` and ``ll_binary`` rules to build modern
C++ with a Clang/LLVM based toolchain built from upstream.

**Features**

- Upstream Clang/LLVM via the
  `llvm-bazel-overlay <https://github.com/llvm/llvm-project/tree/main/utils/bazel>`_.
- Custom overlays for ``libcxx``, ``libcxxabi``, ``libunwind``, ``compiler-rt``
  and ``clang-tidy``.
- Parallel ``clang-tidy`` invocations via an ``ll_compilation_database``
  target.
- Support for sanitizers via target attributes.
- Heterogeneous programming for Nvidia GPUs using HIP and CUDA, including fully
  automated setup of required libraries, toolkits etc.
- C++ modules.

**Links**

- Documentation: `<https://ll.eomii.org>`_
- Examples: `rules_ll/examples <https://github.com/eomii/rules_ll/tree/main/examples>`_
- Discord: `<https://discord.gg/Ax67899n4y>`_

**Planned features**

- HIP/AMD.
- SYCL.
- WebAssembly.
- Aarch64.

System requirements
-------------------

``rules_ll`` makes heavy use of upstream dependencies and experimental features
to the point of sometimes using non-release CI artifacts of Bazel to get
bugfixes faster. If something gets deprecated, we remove it. This means that
the software-side system requirements for ``rules_ll`` tend to be comparatively
high.

Minimum system requirements:

- An ``x86_64`` processor. You can check this via `uname -a`.
- A Linux kernel with 64-bit support. You can check this via
  ``getconf LONG_BIT``.
- A ``glibc`` version that supports ``mallinfo2``. This will be the case if
  ``ldd --version`` prints a value of at least ``2.33``.
- A functional host toolchain for C++. Some distros have this by default,
  others require manual installation of a recent version of Clang or GCC. This
  toolchain will be used to compile the upstream versions of Clang and
  clang-tidy that are used to build ``ll_*`` targets.
- For Nvidia GPU toolchains, a GPU with compute capability of at least ``5.2``.
  This will be the case for 10xx series GPUs and up, as well as some ``9xx``
  series GPUs. A full list of compute capabilities can be found at
  `<https://developer.nvidia.com/cuda-gpus>`_.
- As a rough guideline, at least 10GB of disk space for fetched dependencies
  and build artifacts. Using all toolchains, debug and optimization modes may
  increase this requirement to 30GB of disk space. If the build cache gets too
  large over time it can be reset using the ``bazel clean``
  and ``bazel clean --expunge`` commands.
- As a rough guideline, at least 1GB of Memory per CPU core. You can check the
  number of CPU cores via ``nproc``.

Quickstart
----------

Install `bazelisk <https://bazel.build/install/bazelisk>`_.

If you do not plan on modifying ``rules_ll``, you do not need to clone its
repository. Instead, the following commands are enough to set up a `rules_ll`
workspace:

.. code:: bash

   touch WORKSPACE.bazel .bazelrc
   echo 6.0.0-pre.20220909.2 > .bazelversion
   echo 'bazel_dep(name="rules_ll", version="20220905.0")' > MODULE.bazel

Copy the following lines into the just created ``.bazelrc`` file:

.. code:: bash

   # Upstream LLVM/Clang requires C++17. This will only configure rules_cc.
   build --repo_env=BAZEL_CXXOPTS='-std=c++17'
   run --repo_env=BAZEL_CXXOPTS='-std=c++17'

   # Separate the toolchain from regular code. This will put execution artifacts
   # into bazel-out/ll_linux_exec_platform-opt-exec-<hash>.
   build --experimental_platform_in_output_dir
   run --experimental_platform_in_output_dir

   # We require bzlmod.
   build --experimental_enable_bzlmod
   run --experimental_enable_bzlmod

   # We use a custom registry.
   build --registry=https://raw.githubusercontent.com/eomii/bazel-eomii-registry/main/
   run --registry=https://raw.githubusercontent.com/eomii/bazel-eomii-registry/main/

   # Hash diff (baseline config, transition config) in bazel-out directory names.
   build --experimental_output_directory_naming_scheme=diff_against_baseline
   run --experimental_output_directory_naming_scheme=diff_against_baseline

   # Exec configuration handled by experimental_output_directory_layout.
   build --experimental_exec_configuration_distinguisher=off
   run --experimental_exec_configuration_distinguisher=off

You can now load the ``ll_library`` and ``ll_binary`` rule definitions in your
``BUILD.bazel`` files via

.. code:: python

   load("@rules_ll//ll:defs.bzl", "ll_library", "ll_binary")

See `rules_ll/examples <https://github.com/eomii/rules_ll/tree/main/examples>`_
for examples on how to use ``rules_ll``, or check out the full documentation at
https://ll.eomii.org.

Contributing
------------

Install the required python dependencies::

   pip install -r requirements.txt

Install the ``pre-commit`` hooks::

   pre-commit install

Verify that all tools pass without failure on the entire repository::

   pre-commit run --all-files

Building the documentation
--------------------------

The documentation requires various python dependencies. Install the required
packages via::

   pip install -r requirements.txt

Install the pre-commit

The documentation for this repository is generated via stardoc. Execute the
convenience script ``generate_docs.sh`` to generate the documentation::

   ./generate_docs.sh

Licensing considerations
------------------------

``rules_ll`` is distributed under the Apache 2.0 License.

This repository contains overlays and automated setups for the CUDA toolkit and
HIP. Using ``heterogeneous_mode`` implies acceptance of their licenses.
