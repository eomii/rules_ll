# Using Clang-Tidy

`rules_ll` comes with a Bazel overlay for [`clang-tidy`](https://clang.llvm.org/extra/clang-tidy/).
The `ll_compilation_database` rule can be used to build a [compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
for a target (and its dependencies) and run `clang-tidy` on it.

An example similar to the one described below can be found at [`rules_ll/examples/clang_tidy_example`](https://github.com/eomii/rules_ll/tree/main/examples/clang_tidy_example).

## Basic Usage

For a target `my_library` defined in a `BUILD.bazel` file, we can add an
`ll_compilation_database` like this:

```python
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
    targets = [":my_library"],
    config = ":clang_tidy_config",
)
```

The `targets` attribute in `ll_compilation_database` is used to specify the
targets for which it should generate the `compile_commands.json` file.

The `.clang-tidy` file contains the configuration for `clang-tidy`. See
[rules/ll/examples/.clang-tidy](https://github.com/eomii/rules_ll/tree/main/examples/.clang-tidy)
for an example configuration.

To run `clang-tidy` on the sources of `my_library_compile_commands`, run

```bash
bazel run my_library_compile_commands
# Prints warnings for my_library.cpp.
```

If you only require a `compile_commands.json` file, e.g. for using it with an
IDE, you can build (instead of run) the `compile_commands` target and locate
the `compile_commands.json` file in the `bazel-bin` directory.

```bash
bazel build my_library_compile_commands
# Output is in bazel-bin/k8-fastbuild/bin
```

The output file will always be named `compile_commands.json`, regardless of
the `ll_compilation_database` target's `name` attribute.

## Using Multiple Compilation Databases

The `ll_compilation_database` rule will construct the `compile_commands.json`
file from the `targets` attribute's compile commands and their dependencies'
compile commands. Consider the following targets:

```python
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
    targets = [":mylib_1"],
    config = ":clang_tidy_config",
)

ll_compilation_database(
    name = "cdb_2",
    targets = [":mylib_2"],
    config = ":clang_tidy_config",
)

ll_compilation_database(
   name = "compile_commands",
   targets = [
      ":mylib_1",
      ":mylib_2",
   ],
   config = ":clang_tidy_config",
)
```

Running `cdb_1` will run `clang-tidy` only on `mylib_1.cpp`:

```bash
bazel run cdb_1
# Prints warnings for mylib_1.cpp and mylib_1_additional_source.cpp.
```

Running `cdb_2` will run `clang-tidy` on `mylib_1.cpp` and `mylib_2.cpp`:

```bash
bazel run cdb_2
# Prints warnings for mylib_1.cpp, mylib_2.cpp and
# mylib_1_additional_source.cpp.
```

Running `compile_commands` will also run `clang-tidy` on both targets.

## Limitations

The `ll_compilation_database` rule does not support the `-fix` option for
`clang-tidy`. The auto-fixer tends to break code and would have to work outside
of the Bazel build direcories.
