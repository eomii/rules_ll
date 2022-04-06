An Upstream LLVM/Clang Toolchain for Bazel
------------------------------------------

This repository exposes ``ll_library`` and ``ll_binary`` rules to build C and
C++ code with a Clang/LLVM based toolchain built from upstream.

**Features**

- Uses targets from the
  `llvm-bazel-overlay <https://github.com/llvm/llvm-project/tree/main/utils/bazel>`_
  for Clang, LLVM, etc.
- Comes with custom overlays for ``libcxx``, ``libcxxabi``, ``libunwind`` and
  ``compiler-rt`` and ``clang-tidy`` for a modern, encapsulated toolchain.
- Integrates ``clang-tidy`` via an easy-to-use ``ll_compilation_database``
  target.
- Supports heterogeneous programming for Nvidia GPUs using HIP and CUDA,
  including fully automated setup of required libraries, toolkits etc.
- Support for HIP/AMD is planned.

**Links**

- Examples: `rules_ll/examples <https://github.com/qogecoin/rules_ll/tree/main/examples>`_.
- API Documentation: `<https://qogecoin.github.io/rules_ll>`_
- Discord: `<https://discord.gg/Ax67899n4y>`_

``WORKSPACE.bazel`` Quickstart
------------------------------

The full ``WORKSPACE.bazel`` file created in this guide is available at
`rules_ll/examples <https://github.com/qogecoin/rules_ll/tree/main/examples>`_.

1. Import the ``rules_ll`` repository.

   .. code:: python

      load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

      http_archive(
          name = "rules_ll",
          sha256 = "<Correct SHA256>",
          urls = [
              "https://github.com/qogecoin/rules_ll/archive/<COMMIT_HASH>.zip"
          ]
      )
      load("@rules_ll//ll:deps.bzl", "rules_ll_dependencies")
      rules_ll_dependencies()

2. Executables require the ``crt1.o``, ``crti.o`` and ``crtn.o`` files which
   will be located on your machine in a directory like ``/usr/lib64`` or
   ``/usr/x86_64-unknown-linux-gnu``. Search for their location via

   .. code:: bash

      find /usr/ -name crt*.o

   and initialize ``rules_ll`` with the correct path.

   .. code:: python

      load("@rules_ll//ll:init.bzl", "initialize_rules_ll")
      initialize_rules_ll(
          local_crt_path = "/usr/lib64",
          # llvm_commit,
          # llvm_sha256,
      )

   You may also specify custom llvm commits and their corresponding SHA256
   here, but the overlays will likely break if the specified commit is too far
   away from the current default used by ``rules_ll``.

3. After initializing the ``llvm-raw`` workspace via ``initialize_rules_ll``,
   configure the llvm-bazel-overlay.

   .. code:: python

      load(
          "@llvm-raw//utils/bazel:configure.bzl",
          "llvm_configure",
          "llvm_disable_optional_support_deps",
      )
      llvm_configure(
          name = "llvm-project",
          targets = [
              # Additional targets may be specified here, e.g. "NVPTX" or "AMDGPU".
              "X86",
          ],
      )
      llvm_disable_optional_support_deps()

4. Finally, register the toolchain and the execution platform so that ``ll_*``
   targets can be used in your ``BUILD.bazel`` files.

   .. code:: python

      register_toolchains(
          "@rules_ll//ll:ll_bootstrap_toolchain",
          "@rules_ll//ll:ll_toolchain",
      )
      register_execution_platforms("@rules_ll//ll:ll_linux_exec_platform")

5. You can now make ``ll_library`` and ``ll_binary`` targets available to your
   ``BUILD.bazel`` files via

   .. code:: python

      load("@rules_ll//ll:defs.bzl", "ll_library", "ll_binary")

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
