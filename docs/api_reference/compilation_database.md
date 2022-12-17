# `//ll:compilation_database.bzl`

Implements the `ll_compilation_database` rule.


<a id="ll_compilation_database"></a>

## `ll_compilation_database`

<pre><code>ll_compilation_database(<a href="#ll_compilation_database-name">name</a>, <a href="#ll_compilation_database-config">config</a>, <a href="#ll_compilation_database-exclude">exclude</a>, <a href="#ll_compilation_database-targets">targets</a>)</code></pre>

Executable target for building a
[compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
and running [clang-tidy](https://clang.llvm.org/extra/clang-tidy/) on it.

For a full guide see
[Using `rules_ll` with `clang-tidy`](https://ll.eomii.org/guides/clang_tidy.html).

Examples using this rule are available at
[rules_ll/examples](https://github.com/eomii/rules_ll/tree/main/examples).

`attributes`

| Name  | Description |
| :---- | :---------- |
| <a id="ll_compilation_database-name"></a>`name` | <code><a href="https://bazel.build/docs/build-ref.html#name">Name</a></code>, required.<br><br> A unique name for this target.   |
| <a id="ll_compilation_database-config"></a>`config` | <code><a href="https://bazel.build/docs/build-ref.html#labels">Label</a></code>, required.<br><br> The label of a <code>.clang-tidy</code> configuration file.<br><br>            This file should be at the root of your project directory.   |
| <a id="ll_compilation_database-exclude"></a>`exclude` | <code>List of strings</code>, optional, defaults to <code>[]</code>.<br><br> Exclude all targets whose path includes one at least one of the             provided strings.   |
| <a id="ll_compilation_database-targets"></a>`targets` | <code><a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a></code>, required.<br><br> The label for which the compilation database should be built.   |
