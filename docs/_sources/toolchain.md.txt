<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# `//ll:toolchain.bzl`

Implements `ll_toolchain` and the internally used `ll_bootstrap_toolchain`.


<a id="#ll_bootstrap_toolchain"></a>

## ll_bootstrap_toolchain

<pre>
ll_bootstrap_toolchain(<a href="#ll_bootstrap_toolchain-name">name</a>, <a href="#ll_bootstrap_toolchain-archiver">archiver</a>, <a href="#ll_bootstrap_toolchain-builtin_includes">builtin_includes</a>, <a href="#ll_bootstrap_toolchain-c_driver">c_driver</a>, <a href="#ll_bootstrap_toolchain-cpp_driver">cpp_driver</a>, <a href="#ll_bootstrap_toolchain-linker">linker</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="ll_bootstrap_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="ll_bootstrap_toolchain-archiver"></a>archiver |  The archiver.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//llvm:llvm-ar |
| <a id="ll_bootstrap_toolchain-builtin_includes"></a>builtin_includes |  Builtin header files. Defaults to @llvm-project//clang:builtin_headers_gen   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang:builtin_headers_gen |
| <a id="ll_bootstrap_toolchain-c_driver"></a>c_driver |  The C compiler driver.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang:clang |
| <a id="ll_bootstrap_toolchain-cpp_driver"></a>cpp_driver |  The C++ compiler driver.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang:clang++ |
| <a id="ll_bootstrap_toolchain-linker"></a>linker |  The linker.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//lld:lld |


<a id="#ll_toolchain"></a>

## ll_toolchain

<pre>
ll_toolchain(<a href="#ll_toolchain-name">name</a>, <a href="#ll_toolchain-archiver">archiver</a>, <a href="#ll_toolchain-builtin_includes">builtin_includes</a>, <a href="#ll_toolchain-c_driver">c_driver</a>, <a href="#ll_toolchain-clang_tidy">clang_tidy</a>, <a href="#ll_toolchain-clang_tidy_runner">clang_tidy_runner</a>,
             <a href="#ll_toolchain-compiler_runtime">compiler_runtime</a>, <a href="#ll_toolchain-cpp_driver">cpp_driver</a>, <a href="#ll_toolchain-cpp_stdlib">cpp_stdlib</a>, <a href="#ll_toolchain-linker">linker</a>, <a href="#ll_toolchain-local_crt">local_crt</a>, <a href="#ll_toolchain-symbolizer">symbolizer</a>, <a href="#ll_toolchain-unwind_library">unwind_library</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="ll_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="ll_toolchain-archiver"></a>archiver |  The archiver.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//llvm:llvm-ar |
| <a id="ll_toolchain-builtin_includes"></a>builtin_includes |  Builtin header files for the compiler.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | ["@llvm-project//clang:builtin_headers_gen"] |
| <a id="ll_toolchain-c_driver"></a>c_driver |  The C compiler driver.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang:clang |
| <a id="ll_toolchain-clang_tidy"></a>clang_tidy |  The clang-tidy executable.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang-tools-extra/clang-tidy:clang-tidy |
| <a id="ll_toolchain-clang_tidy_runner"></a>clang_tidy_runner |  The run-clang-tidy.py wrapper script for clang-tidy. Enables multithreading.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang-tools-extra/clang-tidy:run-clang-tidy |
| <a id="ll_toolchain-compiler_runtime"></a>compiler_runtime |  The compiler runtime.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//compiler-rt:libll_compiler-rt |
| <a id="ll_toolchain-cpp_driver"></a>cpp_driver |  The C++ compiler driver.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang:clang++ |
| <a id="ll_toolchain-cpp_stdlib"></a>cpp_stdlib |  The C++ standard library.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//libcxx:libll_cxx |
| <a id="ll_toolchain-linker"></a>linker |  The linker.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//lld:lld |
| <a id="ll_toolchain-local_crt"></a>local_crt |  A filegroup containing the system's local crt1.o, crti.o and crtn.o files.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @local_crt//:crt |
| <a id="ll_toolchain-symbolizer"></a>symbolizer |  The llvm-symbolizer.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//llvm:llvm-symbolizer |
| <a id="ll_toolchain-unwind_library"></a>unwind_library |  The unwinder library.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//libunwind:libll_unwind |
