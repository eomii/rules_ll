# Sanitizers

Sanitizers can improve the robustness of your code.

Full examples at [`rules_ll/examples/sanitizers`](https://github.com/eomii/rules_ll/tree/main/examples/sanitizers).

## Primer

Lots of code-quality tools rely on *static* analysis. A static analyzer like
Clang-Tidy reports errors during *compile time*. This can prevent lots of
issues, but sometimes a bug might slip through the cracks of static analysis.

Sanitizers enable *dynamic* analysis. They report issues during *runtime*.
Sanitizers *instrument* your builds. This means that they instruct Clang to add
instrumentation code around regions of interest. This changes the effective
runtime behavior of your targets. For instance, a memory sanitizer might add
checks and logging around memory access.

The added instrumentation code can incur heavy performance penalties.

## Available sanitizers

You can enable each sanitizer with the `sanitize` attribute in `ll_*` targets:

```python title="BUILD.bazel" hl_lines="4"
ll_binary(
   name = "mytarget"
   srcs = ["main.cpp"],
   sanitize = ["address"],
)

```

At the moment, `rules_ll` supports these values for `sanitize`:

`"address"`

:   Use [AddressSanitizer](https://clang.llvm.org/docs/AddressSanitizer.html),
    to detect memory errors. Slowdown of ~2x. Run targets that invoke
    CUDA-based kernels, with `ASAN_OPTIONS=protect_shadow_gap=0`.

`"leak"`

:   Use [LeakSanitizer](https://clang.llvm.org/docs/LeakSanitizer.html) to
    detect memory leaks. Already part of AddressSanitizer. Use LeakSanitizer if
    you want to use it in standalone mode. Almost no runtime overhead until the
    end of the process where it detects leaks.

`"memory"`

:   Use [MemorySanitizer](https://clang.llvm.org/docs/MemorySanitizer.html)
    to detect uninitialized reads. Slowdown of ~3x. Add
    `"-fsanitize-memory-track-origins=2"` to `compile_flags` to track the
    origins of uninitialized values.

`"undefined_behavior"`

:   Use [UndefinedBehaviorSanitizer](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html)
    to detect undefined behavior. Small runtime overhead.

`"thread"`

:   Use [ThreadSanitizer](https://clang.llvm.org/docs/ThreadSanitizer.html)
    to detect data races. Slowdown of ~5x-15x. Memory overhead of ~5x-10x.

You can combine some of these, but most of them don't play well together. If
possible, use just one at a time.

Since sanitizers detect issues during runtime, they don't yield reproducible
error reports. Run sanitized targets several times and build them with different
optimization levels to maximize coverage.

## Example

This code has a silent use-after-free bug:

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

To verify that the code works as intended, add AddressSanitizer instrumentation
to the target:

```python title="BUILD.bazel" hl_lines="4"
ll_binary(
    name = "bug",
    srcs = ["main.cpp"],
    sanitize = ["address"],
)
```

The sanitizer reports a `heap-use-after-free` bug and where it occurred:

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

To toggle between test and release builds you can add command line flags to your
builds.

This `string_flag` and `config_setting` let you add your sanitizer of choice on
the command line:

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

You can now add the `MYPROJECT_SANITIZE` selector to `ll_*` targets. The
`--//myproject:sanitize=<sanitizer_value>` flag then lets you enable each
sanitizer:

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
