# C++ modules

Apart from clean dependency management, modules can reduce compile times. Try to
use them if you can.

You can find full examples at [`rules_ll/examples`](https://github.com/eomii/rules_ll/tree/main/examples).

<!-- markdownlint-disable code-block-style -->
!!! note

    `rules_ll` has no builtin support for Clang modules. This feature precedes C++
    modules.

    You can't use standard library headers via `import std.iostream;` as you would
    when using Clang modules.

    Due to a bug in `clang-tidy` you have to silence
    `readability-redundant-declaration` when using modules.

!!! warning

    As modules stabilize upstream, expect this API to change in the future.
<!-- markdownlint-enable code-block-style -->

## Basic usage

Consider the following module without implementation:

```cpp title="hello.cppm"
module;

#include <iostream>

export module hello;

export namespace hello {

auto say_hello() -> void {
   std::cout << "Hello from hello interface!" << std::endl;
}

} // namespace hello
```

```cpp title="main.cpp"
import hello;

auto main() -> int {
   hello::say_hello();
   return 0;
}
```

The `rules_ll` build file for this could look like this:

```python title="BUILD.bazel"
load("@rules_ll//ll:defs.bzl", "ll_binary")

ll_binary(
   name = "mybinary",
   srcs = ["main.cpp"],
   interfaces = {"hello.cppm": "hello"},
   compile_flags = ["-std=c++20"],
)
```

The `interfaces` attribute `dict` maps module interfaces to module names.

## Interface-implementation split

Clang expects interfaces to end in `.cppm`:

```cpp title="hello.cpp"
module;

#include <iostream>

module hello;

namespace hello {

auto say_hello_from_implementaion() -> void {
   std::cout << "Hello from implementation!" << std::endl;
}

} // namespace hello
```

```cpp title="hello.cppm"
module;

#include <iostream>

export module hello;

export namespace hello {

auto say_hello_from_implementation() -> void;
auto say_hello_from_interface() -> void {
    std::cout << "Hello from interface!" << std::endl;
}

}
```

```cpp title="main.cpp"
import hello;

auto main() -> int {
   hello::say_hello_from_implementation();
   hello::say_hello_from_interface();
   return 0;
}
```

To build this module, your build file could look like this:

```python title="BUILD.bazel"
load("@rules_ll//ll:defs.bzl", "ll_library", "ll_binary")

ll_library(
   name = "hello",
   srcs = ["hello.cpp"],
   exposed_interfaces = {"hello.cppm": "hello"},
   compile_flags = ["-std=c++20"],
)

ll_binary(
   name = "main",
   srcs = ["main.cpp"],
   deps = [":hello"],
)
```

Use `exposed_interfaces` in `ll_library`. This way the `main` target can see the
interface for the `hello` module.

## Under the hood

For the preceding example, `rules_ll` builds `main` as follows:

![Module compile paths](../images/modules_compile_paths.png){ loading=lazy }

For the `ll_library` target:

- The compiler precompiles `hello.cppm` to `hello.pcm`.
- The compiler compiles `hello.pcm` to `hello.interface.o`. The `.interface`
  part avoids name clashes with outputs from files like `hello.cpp`.
- The compiler compiles `hello.cpp` to `hello.o` using `hello.pcm`.
- By default `ll_library` archives `hello.interface.o` and `hello.o` to
  `hello.a`.  The `name` attribute determines the filename. The archive name
  doesn't depend on the module name. You can change this behavior with the
  `emit` attribute.

For the `ll_binary` target:

- The compiler compiles `main.cpp` to `main.o` using `hello.pcm`. This step
  doesn't depend on `hello.o`.
- The linker links `hello.a` and `main.o` to the final executable `main`.

## Pitfalls

The `exposed` attribute applies to all interfaces in `ll_library`, including
those in the `interfaces` attribute. `rules_ll` builds `interfaces` first and
then makes them visible to `exposed_interfaces`. This way you can declare more
complex modules in a single target.

If you have a dependency chain `a -> b -> c` and you `import c` in a target, you
need to add `deps = [":a", ":b", ":c"]` to that target. The build still requires
the interfaces for `a` and `b`, even though you didn't explicitly specify those
in your code.

## Suggestions

Read the [C++ standard](https://eel.is/c++draft/module) on modules.

Read about [Standard C++ Modules](https://clang.llvm.org/docs/StandardCPlusPlusModules.html)
in Clang.

Name your modules according to [this proposal](https://isocpp.org/files/papers/P1634R0.html).
Use lower-case ASCII characters with `<organization>.<project>.<module_name>` as
naming scheme.

Use namespaces that mimic your module names. This way you can use a symbol `f`
in module `eomii.someproject` as `eomii::someproject::f`.

Use module partitions to keep namespace hierarchies flat.

Use a file layout that reflects your module hierarchies.

## Current state of usability

The module support in `rules_ll` conforms to the standard, but doesn't include
support for header units. Use `#include <iostream>` in global module fragments
instead of `import <iostream>;`.

Clang has unstable, experimental module support. To fix current compiler bugs,
`rules_ll` applies custom patches to `libcxx`.

`rules_ll` adjusts compilation databases emitted by `ll_compilation_database`.
This makes modules work with `clang-tidy`.
