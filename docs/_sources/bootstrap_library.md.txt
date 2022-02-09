<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="#ll_bootstrap_library"></a>

## ll_bootstrap_library

<pre>
ll_bootstrap_library(<a href="#ll_bootstrap_library-name">name</a>, <a href="#ll_bootstrap_library-compile_flags">compile_flags</a>, <a href="#ll_bootstrap_library-defines">defines</a>, <a href="#ll_bootstrap_library-deps">deps</a>, <a href="#ll_bootstrap_library-hdrs">hdrs</a>, <a href="#ll_bootstrap_library-includes">includes</a>, <a href="#ll_bootstrap_library-link_flags">link_flags</a>, <a href="#ll_bootstrap_library-proprietary">proprietary</a>,
                     <a href="#ll_bootstrap_library-srcs">srcs</a>, <a href="#ll_bootstrap_library-transitive_defines">transitive_defines</a>, <a href="#ll_bootstrap_library-transitive_hdrs">transitive_hdrs</a>, <a href="#ll_bootstrap_library-transitive_includes">transitive_includes</a>)
</pre>


Internal use only.

Same as ll_library, but uses a different toolchain.


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="ll_bootstrap_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="ll_bootstrap_library-compile_flags"></a>compile_flags |  Additional flags for the compiler.<br><br>        A list of strings <code>["-O3", "-std=c++20"]</code> will be appended to the         compile command line arguments as <code>-O3 -std=c++20</code>.<br><br>        Only used for this target.   | List of strings | optional | [] |
| <a id="ll_bootstrap_library-defines"></a>defines |  Additional defines for this target.<br><br>        A list of strings <code>["MYDEFINE_1", "MYDEFINE_2"]</code> will add         <code>-DMYDEFINE_1 -DMYDEFINE_2</code> to the compile command line.<br><br>        Defines in this attribute are only used for the current target.   | List of strings | optional | [] |
| <a id="ll_bootstrap_library-deps"></a>deps |  The dependencies for this target.<br><br>        Every dependency needs to be an <code>ll_library</code>.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_bootstrap_library-hdrs"></a>hdrs |  Header files for this target.<br><br>        Headers in this attribute will not be exported, i.e. any generated         include paths are only used for this target.<br><br>        When including header files as <code>#include "some/path/myheader.h"</code> their         include paths need to be specified in the <code>includes</code> attribute as well.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_bootstrap_library-includes"></a>includes |  Additional include paths for this target.<br><br>        When including a header not via <code>#include "header.h"</code>, but via         <code>#include "subdir/header.h"</code>, the include path needs to be added here in         addition to making the header available in the <code>hdrs</code> attribute.   | List of strings | optional | [] |
| <a id="ll_bootstrap_library-link_flags"></a>link_flags |  Additional flags for the linker.<br><br>        This is the place for adding library search paths and external link         targets.<br><br>        Assuming you have a library <code>/some/path/libmylib.a</code> on your host system,         you can make <code>mylib.a</code> available to the linker by passing         <code>["-L/some/path", "-lmylib"]</code> to this attribute.<br><br>        Only used for this target. Only used by <code>ll_binary</code>, since <code>ll_library</code>         does not invoke the linker.   | List of strings | optional | [] |
| <a id="ll_bootstrap_library-proprietary"></a>proprietary |  Setting this to True will disable static linking of glibc.<br><br>        This attribute will be removed as soon as <code>rules_ll</code> uses LLVM's <code>libc</code>.   | Boolean | optional | False |
| <a id="ll_bootstrap_library-srcs"></a>srcs |  Compilable source files for this target.<br><br>        Only compilable files and object files <code>[".o", ".S", ".c", ".cpp"]</code> are         allowed here.<br><br>        Headers should be placed in the <code>hdrs</code> attribute.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_bootstrap_library-transitive_defines"></a>transitive_defines |  Additional transitive defines for this target.<br><br>        These defines will be defined by all depending downstream targets.   | List of strings | optional | [] |
| <a id="ll_bootstrap_library-transitive_hdrs"></a>transitive_hdrs |  Transitive headers for this target.<br><br>        Any transitive headers will be exported (copied) to the build directory.<br><br>        Transitive headers are available to depending downstream targets.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="ll_bootstrap_library-transitive_includes"></a>transitive_includes |  Additional transitive include paths for this target.<br><br>        Includes in this attribute will be added to the compile command line         arguments for all downstream targets.   | List of strings | optional | [] |
