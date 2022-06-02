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

      mkdir myproject
      cd myproject
      touch WORKSPACE.bazel
      touch .bazelrc
      echo 'bazel_dep(name="rules_ll", version="20220602.0")' >> MODULE.bazel

``rules_ll`` uses `bzlmod <https://bazel.build/docs/bzlmod>`_ with the custom
`bazel-eomii-registry <https://github.com/eomii/bazel-eomii-registry>`_ to
resolve its dependencies. This means that the following settings are required
in the previously created ``.bazelrc`` file::

   # We require bzlmod.
   build --experimental_enable_bzlmod
   run --experimental_enable_bzlmod

   # We use a custom registry.
   build --registry=https://raw.githubusercontent.com/eomii/bazel-eomii-registry/main/
   run --registry=https://raw.githubusercontent.com/eomii/bazel-eomii-registry/main/


If you are running 64-bit Gentoo or another operating system where ``crt1.o``,
``crti.o`` and ``crtn.o`` are located at ``/usr/lib64``, you are done.

TODO: The following steps are known to be a bad user experience. Automation
coming soon.

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


Advanced Setup
--------------

To run ``rules_ll`` in a custom configuration, clone the repository and
override the ``bazel_dep`` to ``rules_ll`` with your local copy in your
project's ``MODULE.bazel`` file:

   .. code:: python

      bazel_dep(name="rules_ll", version="20220602.0")
      local_path_override(
          module_name="rules_ll",
          path="/path/to/local/rules_ll",
      )

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
