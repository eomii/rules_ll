# Clang-tidy

`rules_ll` comes with a Bazel overlay for [`clang-tidy`](https://clang.llvm.org/extra/clang-tidy/).
The `ll_compilation_database` rule creates a [compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
for a target and its dependencies. Running that rule invokes `clang-tidy` on it.

You can find similar examples to the ones in this guide at [`rules_ll/examples/clang_tidy_example`](https://github.com/eomii/rules_ll/tree/main/examples/clang_tidy_example).

## Usage

For a target `my_library` defined in a `BUILD.bazel` file, add an
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

The `targets` attribute in `ll_compilation_database` declares the targets
included in the `compile_commands.json` file.

The `.clang-tidy` file configures `clang-tidy`. See
[rules/ll/examples/.clang-tidy](https://github.com/eomii/rules_ll/tree/main/examples/.clang-tidy)
for an example.

To run `clang-tidy` on the sources of `my_library_compile_commands`, run

```bash
bazel run my_library_compile_commands
# Prints warnings for my_library.cpp.
```

If you require a `compile_commands.json` file for using it with an IDE, you can
build instead of run the `compile_commands` target and locate the
`compile_commands.json` file in the `bazel-bin` directory.

```bash
bazel build my_library_compile_commands
# Output in bazel-bin/k8-fastbuild/bin
```

This builds a file named `compile_commands.json`, regardless of the
`ll_compilation_database` target's `name` attribute.

## Compilation databases

The `ll_compilation_database` rule constructs the `compile_commands.json` file
from the `targets` attribute's compile commands and their dependencies' compile
commands. Consider the following targets:

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

Running `cdb_1` invokes `clang-tidy` on `mylib_1.cpp` alone:

```bash
bazel run cdb_1
# Prints warnings for mylib_1.cpp and mylib_1_additional_source.cpp.
```

Running `cdb_2` invokes `clang-tidy` on `mylib_1.cpp` and `mylib_2.cpp`:

```bash
bazel run cdb_2
# Prints warnings for mylib_1.cpp, mylib_2.cpp and
# mylib_1_additional_source.cpp.
```

Running `compile_commands` also invokes `clang-tidy` on both targets.

## Limitations

The `ll_compilation_database` rule doesn't support the `-fix` option for
`clang-tidy`. The auto fixer tends to break code and would have to work outside
of the Bazel build directories.
