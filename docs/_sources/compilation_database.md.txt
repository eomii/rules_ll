<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# `//ll:compilation_database.bzl`

Implements the `ll_compilation_database` rule.


<a id="#ll_compilation_database"></a>

## ll_compilation_database

<pre>
ll_compilation_database(<a href="#ll_compilation_database-name">name</a>, <a href="#ll_compilation_database-config">config</a>, <a href="#ll_compilation_database-exclude">exclude</a>, <a href="#ll_compilation_database-target">target</a>)
</pre>


Executable target for building a
[compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
and running [clang-tidy](https://clang.llvm.org/extra/clang-tidy/) on it.

For a full guide see
[Using `rules_ll` with `clang-tidy`](https://ll.eomii.org/guides/clang_tidy.html).

Examples using this rule are available at
[rules_ll/examples](https://github.com/eomii/rules_ll/tree/main/examples).


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="ll_compilation_database-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="ll_compilation_database-config"></a>config |  The label of a <code>.clang-tidy</code> configuration file.<br><br>            This file should be at the root of your project directory.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="ll_compilation_database-exclude"></a>exclude |  Exclude all targets whose path includes one at least one of the             provided strings.   | List of strings | optional | [] |
| <a id="ll_compilation_database-target"></a>target |  The label for which the compilation database should be built.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
