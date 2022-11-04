<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# `//ll:toolchain.bzl`

Implements `ll_toolchain` and the internally used `ll_bootstrap_toolchain`.


<a id="#ll_toolchain"></a>

## ll_toolchain

<pre>
ll_toolchain(<a href="#ll_toolchain-name">name</a>, <a href="#ll_toolchain-address_sanitizer">address_sanitizer</a>, <a href="#ll_toolchain-archiver">archiver</a>, <a href="#ll_toolchain-bitcode_linker">bitcode_linker</a>, <a href="#ll_toolchain-builtin_includes">builtin_includes</a>, <a href="#ll_toolchain-c_driver">c_driver</a>,
             <a href="#ll_toolchain-clang_tidy">clang_tidy</a>, <a href="#ll_toolchain-clang_tidy_runner">clang_tidy_runner</a>, <a href="#ll_toolchain-compiler_runtime">compiler_runtime</a>, <a href="#ll_toolchain-cpp_abihdrs">cpp_abihdrs</a>, <a href="#ll_toolchain-cpp_abilib">cpp_abilib</a>, <a href="#ll_toolchain-cpp_driver">cpp_driver</a>,
             <a href="#ll_toolchain-cpp_stdhdrs">cpp_stdhdrs</a>, <a href="#ll_toolchain-cpp_stdlib">cpp_stdlib</a>, <a href="#ll_toolchain-cuda_toolkit">cuda_toolkit</a>, <a href="#ll_toolchain-hip_libraries">hip_libraries</a>, <a href="#ll_toolchain-hipsycl_cuda_backend">hipsycl_cuda_backend</a>, <a href="#ll_toolchain-hipsycl_hdrs">hipsycl_hdrs</a>,
             <a href="#ll_toolchain-hipsycl_hip_backend">hipsycl_hip_backend</a>, <a href="#ll_toolchain-hipsycl_omp_backend">hipsycl_omp_backend</a>, <a href="#ll_toolchain-hipsycl_plugin">hipsycl_plugin</a>, <a href="#ll_toolchain-hipsycl_runtime">hipsycl_runtime</a>,
             <a href="#ll_toolchain-leak_sanitizer">leak_sanitizer</a>, <a href="#ll_toolchain-linker">linker</a>, <a href="#ll_toolchain-llvm_project_deps">llvm_project_deps</a>, <a href="#ll_toolchain-local_library_path">local_library_path</a>, <a href="#ll_toolchain-machine_code_tool">machine_code_tool</a>,
             <a href="#ll_toolchain-memory_sanitizer">memory_sanitizer</a>, <a href="#ll_toolchain-offload_bundler">offload_bundler</a>, <a href="#ll_toolchain-symbolizer">symbolizer</a>, <a href="#ll_toolchain-thread_sanitizer">thread_sanitizer</a>,
             <a href="#ll_toolchain-undefined_behavior_sanitizer">undefined_behavior_sanitizer</a>, <a href="#ll_toolchain-unwind_library">unwind_library</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="ll_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="ll_toolchain-address_sanitizer"></a>address_sanitizer |  AddressSanitizer libraries.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_toolchain-archiver"></a>archiver |  The archiver.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//llvm:llvm-ar |
| <a id="ll_toolchain-bitcode_linker"></a>bitcode_linker |  The linker for LLVM bitcode files. While <code>llvm-ar</code> is able         to archive bitcode files into an archive, it cannot link them into         a single bitcode file. We need <code>llvm-link</code> to do this.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//llvm:llvm-link |
| <a id="ll_toolchain-builtin_includes"></a>builtin_includes |  Builtin header files. Defaults to @llvm-project//clang:builtin_headers_gen   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang:builtin_headers_gen |
| <a id="ll_toolchain-c_driver"></a>c_driver |  The C compiler driver.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang:clang |
| <a id="ll_toolchain-clang_tidy"></a>clang_tidy |  The clang-tidy executable.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang-tools-extra/clang-tidy:clang-tidy |
| <a id="ll_toolchain-clang_tidy_runner"></a>clang_tidy_runner |  The run-clang-tidy.py wrapper script for clang-tidy. Enables multithreading.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang-tools-extra/clang-tidy:run-clang-tidy |
| <a id="ll_toolchain-compiler_runtime"></a>compiler_runtime |  The compiler runtime.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_toolchain-cpp_abihdrs"></a>cpp_abihdrs |  The C++ ABI headers.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="ll_toolchain-cpp_abilib"></a>cpp_abilib |  The C++ ABI library archive.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="ll_toolchain-cpp_driver"></a>cpp_driver |  The C++ compiler driver.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang:clang++ |
| <a id="ll_toolchain-cpp_stdhdrs"></a>cpp_stdhdrs |  The C++ standard library headers.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="ll_toolchain-cpp_stdlib"></a>cpp_stdlib |  The C++ standard library archive.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="ll_toolchain-cuda_toolkit"></a>cuda_toolkit |  CUDA toolkit files. <code>rules_ll</code> will still use <code>clang</code> as         the CUDA device compiler. Building targets that make use of the         CUDA libraries imply acceptance of their respective licenses.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_toolchain-hip_libraries"></a>hip_libraries |  HIP library files. <code>rules_ll</code> will use <code>clang</code> as the         device compiler. Building targets that make use of the HIP toolkit         implies acceptance of its license.<br><br>        Using HIP for AMD devices implies the use of the ROCm stack and the         acceptance of its licenses.<br><br>        Using HIP for Nvidia devices implies use of the CUDA toolkit and the         acceptance of its licenses.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_toolchain-hipsycl_cuda_backend"></a>hipsycl_cuda_backend |  TODO   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="ll_toolchain-hipsycl_hdrs"></a>hipsycl_hdrs |  TODO   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_toolchain-hipsycl_hip_backend"></a>hipsycl_hip_backend |  TODO   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="ll_toolchain-hipsycl_omp_backend"></a>hipsycl_omp_backend |  TODO   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="ll_toolchain-hipsycl_plugin"></a>hipsycl_plugin |  TODO   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="ll_toolchain-hipsycl_runtime"></a>hipsycl_runtime |  TODO   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="ll_toolchain-leak_sanitizer"></a>leak_sanitizer |  LeakSanitizer libraries.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_toolchain-linker"></a>linker |  The linker.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//lld:lld |
| <a id="ll_toolchain-llvm_project_deps"></a>llvm_project_deps |  Targets from the <code>llvm-project-overlay</code>. Useful for targets         that require the <code>llvm-project</code>, such as frontend actions, llvm passes,         Clang plugins etc.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | ["@llvm-project//clang:analysis", "@llvm-project//clang:ast", "@llvm-project//clang:ast_matchers", "@llvm-project//clang:basic", "@llvm-project//clang:driver", "@llvm-project//clang:edit", "@llvm-project//clang:frontend", "@llvm-project//clang:lex", "@llvm-project//clang:parse", "@llvm-project//clang:sema", "@llvm-project//clang:serialization", "@llvm-project//clang:support", "@llvm-project//clang:tooling", "@llvm-project//llvm:attributes_gen", "@llvm-project//llvm:AggressiveInstCombine", "@llvm-project//llvm:Analysis", "@llvm-project//llvm:AsmParser", "@llvm-project//llvm:BinaryFormat", "@llvm-project//llvm:BitReader", "@llvm-project//llvm:BitWriter", "@llvm-project//llvm:BitstreamReader", "@llvm-project//llvm:BitstreamWriter", "@llvm-project//llvm:CFGuard", "@llvm-project//llvm:Coroutines", "@llvm-project//llvm:CodeGen", "@llvm-project//llvm:Core", "@llvm-project//llvm:DebugInfoDWARF", "@llvm-project//llvm:Demangle", "@llvm-project//llvm:FrontendOpenMP", "@llvm-project//llvm:IPO", "@llvm-project//llvm:InstCombine", "@llvm-project//llvm:Instrumentation", "@llvm-project//llvm:IRReader", "@llvm-project//llvm:MC", "@llvm-project//llvm:MCParser", "@llvm-project//llvm:Object", "@llvm-project//llvm:Option", "@llvm-project//llvm:Passes", "@llvm-project//llvm:ProfileData", "@llvm-project//llvm:Remarks", "@llvm-project//llvm:Scalar", "@llvm-project//llvm:Support", "@llvm-project//llvm:TextAPI", "@llvm-project//llvm:TransformUtils", "@llvm-project//llvm:Vectorize", "@llvm-project//llvm:WindowsDriver", "@zlib"] |
| <a id="ll_toolchain-local_library_path"></a>local_library_path |  A symlink to the local library path. This is usually either         <code>/usr/lib64</code> or <code>/usr/local/x86_64-linux-gnu</code>.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @local_library_path//:local_library_path |
| <a id="ll_toolchain-machine_code_tool"></a>machine_code_tool |  The llvm-mc tool. Used for separarable compilation (CUDA/HIP).   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//llvm:llvm-mc |
| <a id="ll_toolchain-memory_sanitizer"></a>memory_sanitizer |  MemorySanitizer libraries.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_toolchain-offload_bundler"></a>offload_bundler |  Offload bundler used to bundle code objects for languages         targeting multiple devices in a single source file, e.g. GPU code.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//clang:clang-offload-bundler |
| <a id="ll_toolchain-symbolizer"></a>symbolizer |  The llvm-symbolizer.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @llvm-project//llvm:llvm-symbolizer |
| <a id="ll_toolchain-thread_sanitizer"></a>thread_sanitizer |  ThreadSanitizer libraries.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_toolchain-undefined_behavior_sanitizer"></a>undefined_behavior_sanitizer |  UndefinedBehaviorSanitizer libraries.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_toolchain-unwind_library"></a>unwind_library |  The unwinder library.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
