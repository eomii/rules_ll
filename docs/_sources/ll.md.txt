<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# `//ll:ll.bzl`

Rules for building C/C++ with an upstream LLVM/Clang toolchain.

Build files should import these rules via `@rules_ll//ll:defs.bzl`.


<a id="#ll_binary"></a>

## ll_binary

<pre>
ll_binary(<a href="#ll_binary-name">name</a>, <a href="#ll_binary-aggregate">aggregate</a>, <a href="#ll_binary-compile_flags">compile_flags</a>, <a href="#ll_binary-data">data</a>, <a href="#ll_binary-defines">defines</a>, <a href="#ll_binary-deps">deps</a>, <a href="#ll_binary-hdrs">hdrs</a>, <a href="#ll_binary-includes">includes</a>, <a href="#ll_binary-link_flags">link_flags</a>,
          <a href="#ll_binary-proprietary">proprietary</a>, <a href="#ll_binary-srcs">srcs</a>, <a href="#ll_binary-transitive_defines">transitive_defines</a>, <a href="#ll_binary-transitive_hdrs">transitive_hdrs</a>, <a href="#ll_binary-transitive_includes">transitive_includes</a>)
</pre>


Creates an executable.

Example:

  ```python
  ll_binary(
      srcs = ["my_executable.cpp"],
  )
  ```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="ll_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="ll_binary-aggregate"></a>aggregate |  Sets the aggregation mode for compiled outputs in <code>ll_library</code>.<br><br>        <code>"static"</code> invokes the archiver and creates an archive with a <code>.a</code>         extension.         <code>"bitcode"</code> invokes the bitcode linker and creates a bitcode file with a         <code>.bc</code> extension.         <code>"none"</code> will not invoke any aggregator. Instead, loose files will             be output by the rule.<br><br>        Not used by <code>ll_binary</code>, but <code>ll_library</code> targets with         <code>aggregate = "bitcode"</code> can be used as <code>deps</code> for <code>ll_binary</code>.   | String | optional | "static" |
| <a id="ll_binary-compile_flags"></a>compile_flags |  Additional flags for the compiler.<br><br>        A list of strings <code>["-O3", "-std=c++20"]</code> will be appended to the         compile command line arguments as <code>-O3 -std=c++20</code>.<br><br>        Only used for this target.   | List of strings | optional | [] |
| <a id="ll_binary-data"></a>data |  Additional files made available to the sandboxed actions         executed within this rule. These files are not appended to any command         line arguments, but are part of the inputs to the action and may be         referenced manually via the <code>includes</code>, <code>compile_flags</code> and         <code>link_flags</code> attributes.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_binary-defines"></a>defines |  Additional defines for this target.<br><br>        A list of strings <code>["MYDEFINE_1", "MYDEFINE_2"]</code> will add         <code>-DMYDEFINE_1 -DMYDEFINE_2</code> to the compile command line.<br><br>        Defines in this attribute are only used for the current target.   | List of strings | optional | [] |
| <a id="ll_binary-deps"></a>deps |  The dependencies for this target.<br><br>        Every dependency needs to be an <code>ll_library</code>.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_binary-hdrs"></a>hdrs |  Header files for this target.<br><br>        Headers in this attribute will not be exported, i.e. any generated         include paths are only used for this target.<br><br>        When including header files as <code>#include "some/path/myheader.h"</code> their         include paths need to be specified in the <code>includes</code> attribute as well.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_binary-includes"></a>includes |  Additional include paths for this target.<br><br>        When including a header not via <code>#include "header.h"</code>, but via         <code>#include "subdir/header.h"</code>, the include path needs to be added here in         addition to making the header available in the <code>hdrs</code> attribute.   | List of strings | optional | [] |
| <a id="ll_binary-link_flags"></a>link_flags |  Additional flags for the linker.<br><br>        For <code>ll_binary</code>:         This is the place for adding library search paths and external link         targets.<br><br>        Assuming you have a library <code>/some/path/libmylib.a</code> on your host system,         you can make <code>mylib.a</code> available to the linker by passing         <code>["-L/some/path", "-lmylib"]</code> to this attribute.<br><br>        For <code>ll_library</code>:         If <code>aggregate = "bitcode"</code>, these flags are passed to the bitcode         linker <code>llvm-link</code>.   | List of strings | optional | [] |
| <a id="ll_binary-proprietary"></a>proprietary |  Setting this to True will disable static linking of glibc.<br><br>        This attribute will be removed as soon as <code>rules_ll</code> uses LLVM's <code>libc</code>.   | Boolean | optional | False |
| <a id="ll_binary-srcs"></a>srcs |  Compilable source files for this target.<br><br>        Only compilable files and object files         <code>[".ll", ".o", ".S", ".c", ".cl", ".cpp"]</code> are allowed here.<br><br>        Headers should be placed in the <code>hdrs</code> attribute.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_binary-transitive_defines"></a>transitive_defines |  Additional transitive defines for this target.<br><br>        These defines will be defined by all depending downstream targets.   | List of strings | optional | [] |
| <a id="ll_binary-transitive_hdrs"></a>transitive_hdrs |  Transitive headers for this target.<br><br>        Any transitive headers will be exported (copied) to the build directory.<br><br>        Transitive headers are available to depending downstream targets.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_binary-transitive_includes"></a>transitive_includes |  Additional transitive include paths for this target.<br><br>        Includes in this attribute will be added to the compile command line         arguments for all downstream targets.   | List of strings | optional | [] |


<a id="#ll_library"></a>

## ll_library

<pre>
ll_library(<a href="#ll_library-name">name</a>, <a href="#ll_library-aggregate">aggregate</a>, <a href="#ll_library-compile_flags">compile_flags</a>, <a href="#ll_library-data">data</a>, <a href="#ll_library-defines">defines</a>, <a href="#ll_library-deps">deps</a>, <a href="#ll_library-hdrs">hdrs</a>, <a href="#ll_library-includes">includes</a>, <a href="#ll_library-link_flags">link_flags</a>,
           <a href="#ll_library-proprietary">proprietary</a>, <a href="#ll_library-srcs">srcs</a>, <a href="#ll_library-transitive_defines">transitive_defines</a>, <a href="#ll_library-transitive_hdrs">transitive_hdrs</a>, <a href="#ll_library-transitive_includes">transitive_includes</a>)
</pre>


Creates a static archive.

Example:

  ```python
  ll_library(
      srcs = ["my_library.cpp"],
  )
  ```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="ll_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="ll_library-aggregate"></a>aggregate |  Sets the aggregation mode for compiled outputs in <code>ll_library</code>.<br><br>        <code>"static"</code> invokes the archiver and creates an archive with a <code>.a</code>         extension.         <code>"bitcode"</code> invokes the bitcode linker and creates a bitcode file with a         <code>.bc</code> extension.         <code>"none"</code> will not invoke any aggregator. Instead, loose files will             be output by the rule.<br><br>        Not used by <code>ll_binary</code>, but <code>ll_library</code> targets with         <code>aggregate = "bitcode"</code> can be used as <code>deps</code> for <code>ll_binary</code>.   | String | optional | "static" |
| <a id="ll_library-compile_flags"></a>compile_flags |  Additional flags for the compiler.<br><br>        A list of strings <code>["-O3", "-std=c++20"]</code> will be appended to the         compile command line arguments as <code>-O3 -std=c++20</code>.<br><br>        Only used for this target.   | List of strings | optional | [] |
| <a id="ll_library-data"></a>data |  Additional files made available to the sandboxed actions         executed within this rule. These files are not appended to any command         line arguments, but are part of the inputs to the action and may be         referenced manually via the <code>includes</code>, <code>compile_flags</code> and         <code>link_flags</code> attributes.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_library-defines"></a>defines |  Additional defines for this target.<br><br>        A list of strings <code>["MYDEFINE_1", "MYDEFINE_2"]</code> will add         <code>-DMYDEFINE_1 -DMYDEFINE_2</code> to the compile command line.<br><br>        Defines in this attribute are only used for the current target.   | List of strings | optional | [] |
| <a id="ll_library-deps"></a>deps |  The dependencies for this target.<br><br>        Every dependency needs to be an <code>ll_library</code>.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_library-hdrs"></a>hdrs |  Header files for this target.<br><br>        Headers in this attribute will not be exported, i.e. any generated         include paths are only used for this target.<br><br>        When including header files as <code>#include "some/path/myheader.h"</code> their         include paths need to be specified in the <code>includes</code> attribute as well.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_library-includes"></a>includes |  Additional include paths for this target.<br><br>        When including a header not via <code>#include "header.h"</code>, but via         <code>#include "subdir/header.h"</code>, the include path needs to be added here in         addition to making the header available in the <code>hdrs</code> attribute.   | List of strings | optional | [] |
| <a id="ll_library-link_flags"></a>link_flags |  Additional flags for the linker.<br><br>        For <code>ll_binary</code>:         This is the place for adding library search paths and external link         targets.<br><br>        Assuming you have a library <code>/some/path/libmylib.a</code> on your host system,         you can make <code>mylib.a</code> available to the linker by passing         <code>["-L/some/path", "-lmylib"]</code> to this attribute.<br><br>        For <code>ll_library</code>:         If <code>aggregate = "bitcode"</code>, these flags are passed to the bitcode         linker <code>llvm-link</code>.   | List of strings | optional | [] |
| <a id="ll_library-proprietary"></a>proprietary |  Setting this to True will disable static linking of glibc.<br><br>        This attribute will be removed as soon as <code>rules_ll</code> uses LLVM's <code>libc</code>.   | Boolean | optional | False |
| <a id="ll_library-srcs"></a>srcs |  Compilable source files for this target.<br><br>        Only compilable files and object files         <code>[".ll", ".o", ".S", ".c", ".cl", ".cpp"]</code> are allowed here.<br><br>        Headers should be placed in the <code>hdrs</code> attribute.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_library-transitive_defines"></a>transitive_defines |  Additional transitive defines for this target.<br><br>        These defines will be defined by all depending downstream targets.   | List of strings | optional | [] |
| <a id="ll_library-transitive_hdrs"></a>transitive_hdrs |  Transitive headers for this target.<br><br>        Any transitive headers will be exported (copied) to the build directory.<br><br>        Transitive headers are available to depending downstream targets.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_library-transitive_includes"></a>transitive_includes |  Additional transitive include paths for this target.<br><br>        Includes in this attribute will be added to the compile command line         arguments for all downstream targets.   | List of strings | optional | [] |
