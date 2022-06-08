An Upstream LLVM/Clang Toolchain for Bazel
------------------------------------------

This repository exposes ``ll_library`` and ``ll_binary`` rules to build C and
C++ code with a Clang/LLVM based toolchain built from upstream.

**Features**

- Clang/LLVM via the
  `llvm-bazel-overlay <https://github.com/llvm/llvm-project/tree/main/utils/bazel>`_.
- Custom overlays for ``libcxx``, ``libcxxabi``, ``libunwind`` and
  ``compiler-rt`` and ``clang-tidy`` for a modern, encapsulated toolchain.
- Multithreaded ``clang-tidy`` via an ``ll_compilation_database`` target.
- Heterogeneous programming for Nvidia GPUs using HIP and CUDA, including fully
  automated setup of required libraries, toolkits etc.

**Links**

- Documentation: `<https://ll.eomii.org>`_
- Examples: `rules_ll/examples <https://github.com/eomii/rules_ll/tree/main/examples>`_.
- Discord: `<https://discord.gg/Ax67899n4y>`_

**Planned features**

- HIP/AMD.
- SYCL.
- WebAssembly.
- Aarch64.

Quickstart
----------

Install Bazel using `bazelisk <https://bazel.build/install/bazelisk>`_.

The following commands set up a ``rules_ll`` workspace:

.. code:: bash

   git clone git@github.com:eomii/rules_ll.git
   mkdir myproject
   cd myproject
   touch WORKSPACE.bazel MODULE.bazel .bazelrc

Copy the following lines into the just created ``.bashrc`` file::

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

Copy the following lines into the ``MODULE.bazel`` file:

.. code:: python

   bazel_dep(name="rules_ll", version="20220608.0")
   local_path_override(
       module_name="rules_ll",
       path="../rules_ll",
   )

If you are running 64-bit Gentoo or another operating system where ``crt1.o``,
``crti.o`` and ``crtn.o`` are located at ``/usr/lib64``, you are done.

Otherwise, you need to locate the directory containing the ``crt*.o`` files on
your operating system

.. code:: bash

   find /usr/ -name crt*.o

and create a symbolic link ``/usr/lib64 -> <your crt directory>``.

.. code:: bash

   ln -s <your crt directory> /usr/lib64

You can now load the ``ll_library`` and ``ll_binary`` rule definitions in your
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
