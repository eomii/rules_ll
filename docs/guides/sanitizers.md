# Sanitizers

Sanitizers are an essential tool to ensure the robustness of modern
applications. To use sanitizers with `rules_ll`, only a few small changes to
your build files are required.

Examples for all sanitizers are available at
[rules_ll/examples/sanitizers](https://github.com/eomii/rules_ll/tree/main/examples/sanitizers).

## Primer

Many code-quality tools rely on *static* analysis. An example of this is
Clang-Tidy which operates during *compile time*. Static analyzers catch many
potential bugs early, but often operate on a per-translation-unit basis and may,
for instance, be unable to catch bugs that arise from the interactions between
different translation units.

Sanitizers enable *dynamic* analysis of code. A sanitizer will report issues
during *runtime*. Sanitized builds are *instrumented*, meaning that they
instruct the compiler to add additional instrumentation code around regions of
interest. This happens during compilation and modifies the runtime behavior of
the target. For instance, a memory sanitizer may add additional checks and
logging around memory management. This may produce very insightful information
if memory is mismanaged.

The added instrumentation code may incur heavy runtime performance penalties. As
such, sanitizers are often not suited to be used in release builds. However,
they can be an invaluable tool to uncover subtle bugs during development.

## Available sanitizers

Sanitizers may be enabled by setting their corresponding identifier in the
`sanitize` attribute of an `ll_*` target.

```python title="BUILD.bazel" hl_lines="4"
ll_binary(
   name = "mytarget"
   srcs = ["main.cpp"],
   sanitize = ["address"],
)

```

Valid settings for `sanitize` values are:

`"address"`

: Enable [AddressSanitizer](https://clang.llvm.org/docs/AddressSanitizer.html),
  to detect memory errors. Typical slowdown introduced
  is 2x. Executables that invoke CUDA-based kernels, including those created via
  HIP and SYCL, need to be run with `ASAN_OPTIONS=protect_shadow_gap=0`.

`"leak"`

: Enable [LeakSanitizer](https://clang.llvm.org/docs/LeakSanitizer.html) to
  detect memory leaks. This is already integrated in AddressSanitizer. Enable
  LeakSanitizer if you want to use it in standalone mode. Almost no performance
  overhead until the end of the process where leaks are detected.

`"memory"`

: Enable [MemorySanitizer](https://clang.llvm.org/docs/MemorySanitizer.html) to
  detect uninitialized reads. Typical slowdown introduced is 3x. Add
  `"-fsanitize-memory-track-origins=2"` to the `compile_flags` attribute to
  track the origins of uninitialized values.

`"undefined_behavior"`

: Enable [UndefinedBehaviorSanitizer](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html)
  to detect undefined behavior. Small performance overhead.

`"thread"`

: Enable [ThreadSanitizer](https://clang.llvm.org/docs/ThreadSanitizer.html) to
  detect data races. Typical slowdown is 5x-15x. Typical memory overhead is
  5x-10x.

Some sanitizers may be combined, but many combinations will be invalid. If
possible, use only one at a time.

Since sanitizers detect issues during runtime, error reports are
nondeterministic and not reproducible at an address level. Run sanitized
executables multiple times and build them with different optimization levels to
maximize coverage.

## Simple example

The following code will introduce a silent use-after-free bug:

```cpp title="main.cpp"
int main(int argc, char **argv) {
  int *array = new int[100];
  delete[] array;
  return array[argc];  // Bad.
}
```

```python title="BUILD.bazel"
ll_binary(
   name = "bug"
   srcs = ["main.cpp"],
)

```

```bash
bazel run bug
# Appears to run fine.
```

To make sure that our code behaves correctly, we decide to add AddressSanitizer
instrumentation to the target:

```python title="BUILD.bazel" hl_lines="4"
ll_binary(
    name = "bug",
    srcs = ["main.cpp"],
    sanitize = ["address"],
)
```

We are immediately informed about a `heap-use-after-free` bug, along with a
detailed report on where we introduced it:

```bash
bazel run bug
```

```cpp
=================================================================
==220498==ERROR: AddressSanitizer: heap-use-after-free on address
  0x614000000048 at pc 0x5645a5c68118 bp 0x7ffe69c17f40 sp 0x7ffe69c17f20

READ of size 4 at 0x614000000048 thread T0
    #0 0x5645a5c68117 in main main.cpp:4:10
    #1 0x7efdaa1f32c9  (/usr/lib64/libc.so.6+0x232c9)
    #2 0x7efdaa1f3384 in __libc_start_main (/usr/lib64/libc.so.6+0x23384)
    #3 0x5645a5b23610 in _start (bug+0x6e610)

0x614000000048 is located 8 bytes inside of 400-byte region
  [0x614000000040,0x6140000001d0)

freed by thread T0 here:
    #0 0x5645a5c64e18 in operator delete[](void*) (bug+0x1afe18)
    #1 0x5645a5c680cc in main main.cpp:3:3
    #2 0x7efdaa1f32c9  (/usr/lib64/libc.so.6+0x232c9)

previously allocated by thread T0 here:
    #0 0x5645a5c6447c in operator new[](unsigned long) (bug+0x1af47c)
    #1 0x5645a5c680ad in main main.cpp:2:16
    #2 0x7efdaa1f32c9  (/usr/lib64/libc.so.6+0x232c9)

SUMMARY: AddressSanitizer: heap-use-after-free main.cpp:4:10 in main
Shadow bytes around the buggy address:
  0x613ffffffd80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x613ffffffe00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x613ffffffe80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x613fffffff00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x613fffffff80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
=>0x614000000000: fa fa fa fa fa fa fa fa fd[fd]fd fd fd fd fd fd
  0x614000000080: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
  0x614000000100: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
  0x614000000180: fd fd fd fd fd fd fd fd fd fd fa fa fa fa fa fa
  0x614000000200: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x614000000280: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
==220498==ABORTING
```

## Usage in build files

We will generally want to switch back and forth between sanitized and
non-sanitized builds. A straightforward way to make this possible with
`rules_ll` is to add command line flags to the build to select a specific
sanitizer.

The code below, declares a `string_flag` containing the possible sanitizer
identifiers and a `config_setting` for each possible value. This way we can
select the corresponding sanitizer during our build invocations:

```python title="myproject/BUILD.bazel"
SANITIZERS = [
    "address",
    "leak",
    "memory",
    "none",
    "thread",
    "undefined_behavior",
]

string_flag(
    name = "sanitize",
    build_setting_default = "none",
    values = SANITIZERS,
)

[
    config_setting(
        name = sanitizer,
        flag_values = {":sanitize": sanitizer},
    )
    for sanitizer in SANITIZERS
]

MYPROJECT_SANITIZE = select({
    sanitizer: [sanitizer]
    for sanitizer in SANITIZERS
})
```

The `MYPROJECT_SANITIZE` selector can now be added to every `ll_*` target and we
can enable each sanitizer by setting the selector to the corresponding sanitizer
name:

```python
ll_library(
   name = "mylib",
   srcs = ["mylib.cpp"],
   exposed_hdrs = ["mylib_public_api.hpp"],
   sanitize = MYPROJECT_SANITIZE,
)

ll_binary(
   name = "myproject",
   srcs = ["main.cpp"],
   deps = [":mylib"],
   sanitize = MYPROJECT_SANITIZE,
)
```

```bash
bazel run --//myproject:sanitize=address myproject
# Builds with address sanitizer and runs the executable.
```
