# C++ modules

`rules_ll` supports C++ modules. This document describes how to write targets
that use C++ modules.

Apart from clean dependency management, modules can reduce compile times
significantly. In settings where there are many targets that use
expensive-to-compile headers (such as CUDA, HIP and SYCL), the compile-time
improvements from using modules are invaluable.

The `ll_compilation_database` target works for modules. Due to a bug in
`clang-tidy` you will have to disable `readability-redundant-declaration`
when using modules.

Additional examples to the ones in this guide can be found at [rules_ll/examples](https://github.com/eomii/rules_ll/tree/main/examples).

!!! note

    Do not confuse C++ modules with Clang modules. The former is the variant
    described by the C++ standard, while the latter is a compiler-specific
    implementation of a very similar concept.

    `rules_ll` has no builtin support for Clang modules and does not intend to
    implement it. Instead, we will add support for header units in the future.

    A consequence of this is that you cannot use standard library headers via
    `import std.iostream;` as you would when using Clang modules. Instead, use
    `#include <iostream>` in global module fragments.

## Basic usage

An interface-only module can be written as follows:

```cpp
// hello.cppm
module;

#include <iostream>

export module hello;

export namespace hello {

auto say_hello() -> void {
   std::cout << "Hello from hello interface!" << std::endl;
}

} // namespace hello
```

```cpp
// main.cpp
import hello;

auto main() -> int {
   hello::say_hello();
   return 0;
}
```

The `rules_ll` build file for this may look like this:

```python
load("@rules_ll//ll:defs.bzl", "ll_binary")

ll_binary(
   srcs = ["main.cpp"],
   interfaces = {"hello.cppm": "hello"},
   compile_flags = ["-std=c++20"],
)
```

The `interfaces` attribute is a `dict`, mapping module interface units to
module names. This lets us declare several interfaces in a single target and use
different names for the target name, the interface files and the module name.

## Interface-implementation split

Similar to headers, we may have separate module interface units and module
implementation units for a module. When using `rules_ll`, interfaces should
end with `.cppm`, while implementations should end with `cpp`:

```cpp
// hello.cpp
module;

#include <iostream>

module hello;

namespace hello {

auto say_hello_from_implementaion() -> void {
   std::cout << "Hello from hello interface implementation!" << std::endl;
}

} // namespace hello
```

```cpp
// hello.cppm
module;

#include <iostream>

export module hello;

export namespace hello {

auto say_hello_from_implementation() -> void;
auto say_hello_from_interface() -> void {
    std::cout << "Hello from hello interface implementation!" << std::endl;
}

}
```

```cpp
// main.cpp
import hello;

auto main() -> int {
   hello::say_hello_from_implementation();
   hello::say_hello_from_interface();
   return 0;
}
```

To build this, we could do something like:

```python
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

In this case, we had to make the interface for the `hello` module available to
the `main` target, so we used `exposed_interfaces` instead of `interfaces`.

## Under the hood

For the example above, `rules_ll` will build `main` as follows:

![Module compile paths](../images/modules_compile_paths.png){ loading=lazy }

For the `ll_library` target:

- `hello.cppm` is precompiled to `hello.pcm`. This is a more-or-less AST
  dump of `hello.cppm`.
- `hello.pcm` is compiled to `hello.interface.o`. Don't confuse modules with
  precompiled headers or header units. We need to compile and link the module
  interface unit just like a regular translation unit. The `.interface` part is
  appended so that we don't clash names with outputs from files like
  `hello.cpp`.
- `hello.cpp` is compiled to `hello.o`. This is more or less regular
  compilation, with the only difference being that `hello.pcm` is loaded by
  the compiler to make the interface of the `hello` module available to the
  compilation.
- `hello.interface.o` and `hello.o` are archived to `hello.a`. If we
  didn't have an `ll_library` target to encapsulate the `hello` module, we
  would skip this step. The archive is named after the `name` attribute in
  `ll_library`, just like in any other `ll_library` target. Had we named
  our target `some_other_target`, the archive would be
  `some_other_target.a`, despite the module declared by our code being the
  `hello` module.

For the `ll_binary` target:

- `main.cpp` is compiled to `main.o`. This, again, is more or less regular
  compilation but with an additional directive to the compiler to load
  `hello.pcm`. Note that this step doesn't depend on the existence of
  `hello.o`. The precompiled module interface is loaded since we specified
  `":hello"` in our `deps`, and `rules_ll` knows how to handle
  precompiled interface units transitively.
- `hello.a` and `main.o` are linked to the final executable `main`.

## General guidelines

Consider reading the [C++ standard](https://eel.is/c++draft/module) on modules.

Consider reading about [Standard C++ Modules](https://clang.llvm.org/docs/StandardCPlusPlusModules.html)
in Clang.

Consider naming your modules according to [this proposal](https://isocpp.org/files/papers/P1634R0.html),
namely, using lower-case ASCII characters and using
`<organization>.<project>.<module_name>` as naming scheme.

Consider using namespaces in your module implementation units and module
interface units that mimic the dotted module names. This way a function `f`
in module `eomii.someproject` may be used as `eomii::someproject::f`.

Consider using module partitions over deeply nested submodule hierarchies to
keep namespace hierarchies flat.

Consider mimicking module hierarchies with file layouts.

## Current state of usability

In theory, the functionality implemented in `rules_ll` is standards-conform.
As such, code written using C++ modules that builds with `rules_ll` should
be buildable on any other build system with any other compiler that supports
the C++ standard.

In practice, most build systems don't yet implement the logic required to work
with C++ modules. They work in `rules_ll` because we use upstream versions of
Clang and apply custom patches to `libcxx`. We also create modified
compilation databases so that `clang-tidy` doesn't get confused by binary
inputs from intermediate precompilation steps.

Most build systems won't set up a customized standard library for you, or
integrate tooling as deeply as `rules_ll`, so it will likely take some time
until C++ modules become general practice.

If you find bugs, please let us know so that we can figure out whether your
issues are from the implementation in `rules_ll` or in Clang/LLVM.
