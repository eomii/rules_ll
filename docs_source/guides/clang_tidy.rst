Using ``clang-tidy`` with ``rules_ll``
--------------------------------------

``rules_ll`` comes with a Bazel overlay for ``clang-tidy``. The
``ll_compilation_database`` rule can be used to build a `compilation database <https://clang.llvm.org/docs/JSONCompilationDatabase.html>`_
for a target (and its dependencies) and run ``clang-tidy`` on it.

An example similar to the one described below can be found at `rules_ll/examples <https://github.com/eomii/rules_ll/tree/main/examples>`_

Basic Usage
===========

For a target ``my_library`` defined in a ``BUILD.bazel`` file, we can add an
``ll_compilation_database`` like this:

.. code:: python

   load("@rules_ll//ll:defs.bzl", "ll_library", "ll_compilation_database")

   filegroup(
      name = "clang_tidy_config",
      srcs = [".clang-tidy"],
   )

   ll_library(
       name = "my_library",
       srcs = ["my_library.cpp"],
   )

   ll_compilation_database(
       name = "my_library_compile_commands",
       target = ":my_library",
       config = ":clang_tidy_config",
   )

The ``target`` attribute in ``ll_compilation_database`` is used to specify the
target for which it should generate the ``compile_commands.json`` file.

The ``.clang-tidy`` file contains the configuration for ``clang-tidy``. See
`rules/ll/examples/.clang-tidy <https://github.con/eomii/rules_ll/tree/main/examples/.clang-tidy>`_
for an example configuration.

To run ``clang-tidy`` on the sources of ``my_library_compile_commands``, run

.. code:: bash

   bazel run my_library_compile_commands
   # Prints warnings for my_library.cpp.

If you only require a ``compile_commands.json`` file, e.g. for using it with an
IDE, you can build (instead of run) the ``compile_commands`` target and locate
the ``compile_commands.json`` file in the ``bazel-bin`` directory.

.. code:: bash

   bazel build my_library_compile_commands
   # Output is in bazel-bin/k8-fastbuild/bin

The output file will always be named ``compile_commands.json``, regardless of
the ``ll_compilation_database`` target's ``name`` attribute.

Using Multiple Compilation Databases
====================================

The ``ll_compilation_database`` rule will construct the
``compile_commands.json`` file from the ``target`` attribute's compile commands
and its dependencies' compile commands. Consider the following targets:

.. code:: python

   filegroup(
      name = "clang_tidy_config",
      srcs = [".clang-tidy"],
   )

   ll_library(
       name = "mylib_1",
       srcs = [
           "mylib_1.cpp",
           "mylib_1_additional_source.cpp",
       ]
   )

   ll_library(
       name = "mylib_2",
       srcs = "mylib_2.cpp",
       deps = [
           ":mylib_1",
       ]
   )

   ll_compilation_database(
       name = "cdb_1",
       target = ":mylib_1",
       config = ":clang_tidy_config",
   )

   ll_compilation_database(
       name = "cdb_2",
       target = ":mylib_2",
       config = ":clang_tidy_config",
   )

Running ``cdb_1`` will run ``clang-tidy`` only on ``mylib_1.cpp``:

.. code:: bash

   bazel run cdb_1
   # Prints warnings for mylib_1.cpp and mylib_1_additional_source.cpp.

Running ``cdb_2`` will run ``clang-tidy`` on ``mylib_1.cpp`` and
``mylib_2.cpp``:

.. code:: bash

   bazel run cdb_2
   # Prints warnings for mylib_1.cpp, mylib_2.cpp and
   # mylib_1_additional_source.cpp.

Limitations
===========

``ll_compilation_database`` currently does not support the ``-fix`` option for
``clang-tidy``. The auto-fixer tends to break code and would have to work
outside of the Bazel build direcories.

For complex projects one may lose track of multiple ``ll_compilation_database``
targets. Support for multiple targets in ``ll_compilation_database`` for easier
global compile command generation is planned.
