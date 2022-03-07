<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# `//ll:bootstrap_library.bzl`

This rule is used by `rules_ll` to boostrap `compiler-rt`, `libcxx`,
`libcxxabi` and `libunwind`. Users should use `ll_library` instead.


<a id="#ll_bootstrap_library"></a>

## ll_bootstrap_library

<pre>
ll_bootstrap_library(<a href="#ll_bootstrap_library-name">name</a>, <a href="#ll_bootstrap_library-aggregate">aggregate</a>, <a href="#ll_bootstrap_library-bitcode_libraries">bitcode_libraries</a>, <a href="#ll_bootstrap_library-bitcode_link_flags">bitcode_link_flags</a>, <a href="#ll_bootstrap_library-compile_flags">compile_flags</a>, <a href="#ll_bootstrap_library-data">data</a>,
                     <a href="#ll_bootstrap_library-defines">defines</a>, <a href="#ll_bootstrap_library-deps">deps</a>, <a href="#ll_bootstrap_library-hdrs">hdrs</a>, <a href="#ll_bootstrap_library-includes">includes</a>, <a href="#ll_bootstrap_library-srcs">srcs</a>, <a href="#ll_bootstrap_library-transitive_defines">transitive_defines</a>, <a href="#ll_bootstrap_library-transitive_hdrs">transitive_hdrs</a>,
                     <a href="#ll_bootstrap_library-transitive_includes">transitive_includes</a>)
</pre>


Internal use only.

Same as ll_library, but uses a different toolchain.


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="ll_bootstrap_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="ll_bootstrap_library-aggregate"></a>aggregate |  Sets the aggregation mode for compiled outputs in <code>ll_library</code>.<br><br>        <code>"static"</code> invokes the archiver and creates an archive with a <code>.a</code>         extension.         <code>"bitcode"</code> invokes the bitcode linker and creates a bitcode file with a         <code>.bc</code> extension.         <code>"none"</code> will not invoke any aggregator. Instead, loose object files         will be output by the rule.<br><br>        Not used by <code>ll_binary</code>, but <code>ll_library</code> targets with         <code>aggregate = "bitcode"</code> can be used as <code>deps</code> for <code>ll_binary</code>.   | String | optional | "static" |
| <a id="ll_bootstrap_library-bitcode_libraries"></a>bitcode_libraries |  Bitcode libraries that should always be linked.<br><br>        Only used if <code>aggregate = "bitcode"</code>.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_bootstrap_library-bitcode_link_flags"></a>bitcode_link_flags |  Additional flags for the bitcode linker.<br><br>        If <code>aggregate = "bitcode"</code>, these flags are passed to the bitcode         linker. The default bitcode linker is <code>llvm-link</code>.   | List of strings | optional | [] |
| <a id="ll_bootstrap_library-compile_flags"></a>compile_flags |  Additional flags for the compiler.<br><br>        A list of strings <code>["-O3", "-std=c++20"]</code> will be appended to the         compile command line arguments as <code>-O3 -std=c++20</code>.<br><br>        Flag pairs like <code>-Xclang -somearg</code> need to be split into separate flags         <code>["-Xclang", "-somearg"]</code>.<br><br>        Only used for this target.   | List of strings | optional | [] |
| <a id="ll_bootstrap_library-data"></a>data |  Additional files made available to the sandboxed actions         executed within this rule. These files are not appended to the default         line arguments, but are part of the inputs to the actions and may be         added to command line arguments manually via the <code>includes</code>,         and <code>compile_flags</code> (for <code>ll_binary also </code>link_flags<code>) attributes.<br><br>        This attribute may be used to make intermediary outputs from non-ll         targets (e.g. from </code>rules_cc<code> or </code>filegroup<code>) available to the rule.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_bootstrap_library-defines"></a>defines |  Additional defines for this target.<br><br>        A list of strings <code>["MYDEFINE_1", "MYDEFINE_2"]</code> will add         <code>-DMYDEFINE_1 -DMYDEFINE_2</code> to the compile command line.<br><br>        Only used for this target.   | List of strings | optional | [] |
| <a id="ll_bootstrap_library-deps"></a>deps |  The dependencies for this target.<br><br>        Every dependency needs to be an <code>ll_library</code>.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_bootstrap_library-hdrs"></a>hdrs |  Header files for this target.<br><br>        Headers in this attribute will not be exported, i.e. any generated         include paths are only used for this target and the header files are         not made available to downstream targets.<br><br>        When including header files as <code>#include "some/path/myheader.h"</code> their         include paths need to be specified in the <code>includes</code> attribute as well.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_bootstrap_library-includes"></a>includes |  Additional include paths for this target.<br><br>        When including a header not via <code>#include "header.h"</code>, but via         <code>#include "subdir/header.h"</code>, the include path needs to be added here in         addition to making the header available in the <code>hdrs</code> attribute.<br><br>        Only used for this target.   | List of strings | optional | [] |
| <a id="ll_bootstrap_library-srcs"></a>srcs |  Compilable source files for this target.<br><br>        Only compilable files and object files         <code>[".ll", ".o", ".S", ".c", ".cl", ".cpp"]</code> are allowed here.<br><br>        Headers should be placed in the <code>hdrs</code> attribute.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_bootstrap_library-transitive_defines"></a>transitive_defines |  Additional transitive defines for this target.<br><br>        These defines will be defined by all depending downstream targets.   | List of strings | optional | [] |
| <a id="ll_bootstrap_library-transitive_hdrs"></a>transitive_hdrs |  Transitive headers for this target.<br><br>        Any transitive headers will be exported (copied) to the build directory.<br><br>        Transitive headers are available to depending downstream targets.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_bootstrap_library-transitive_includes"></a>transitive_includes |  Additional transitive include paths for this target.<br><br>        Includes in this attribute will be added to the compile command line         arguments for all downstream targets.   | List of strings | optional | [] |
