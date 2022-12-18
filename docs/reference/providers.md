# `//ll:providers.bzl`

Providers used by `rules_ll`.


<a id="LlCompilationDatabaseFragmentsInfo"></a>

## `LlCompilationDatabaseFragmentsInfo`

<pre><code>LlCompilationDatabaseFragmentsInfo(<a href="#LlCompilationDatabaseFragmentsInfo-cdfs">cdfs</a>)</code></pre>
Provider containing compilation database fragments.

`fields`


| Name  | Description |
| :------------- | :------------- |
| <a id="LlCompilationDatabaseFragmentsInfo-cdfs"></a>`cdfs` |  A depset containing compilation database fragments.<br><br>        Assembling the compilation database fragments into a         <code>compile_commands.json</code> file produces a compilation database for tools         like clang-tidy.    |


<a id="LlCompilationDatabaseInfo"></a>

## `LlCompilationDatabaseInfo`

<pre><code>LlCompilationDatabaseInfo(<a href="#LlCompilationDatabaseInfo-compilation_database">compilation_database</a>)</code></pre>


`fields`


| Name  | Description |
| :------------- | :------------- |
| <a id="LlCompilationDatabaseInfo-compilation_database"></a>`compilation_database` |  A compile_commands.json file containing a         compilation database.    |


<a id="LlInfo"></a>

## `LlInfo`

<pre><code>LlInfo(<a href="#LlInfo-exposed_angled_includes">exposed_angled_includes</a>, <a href="#LlInfo-exposed_defines">exposed_defines</a>, <a href="#LlInfo-exposed_hdrs">exposed_hdrs</a>, <a href="#LlInfo-exposed_includes">exposed_includes</a>, <a href="#LlInfo-exposed_bmis">exposed_bmis</a>)</code></pre>
Provider returned by ll targets.

`fields`


| Name  | Description |
| :------------- | :------------- |
| <a id="LlInfo-exposed_angled_includes"></a>`exposed_angled_includes` |  A depset containing angled include paths.    |
| <a id="LlInfo-exposed_defines"></a>`exposed_defines` |  A depset containing defines.    |
| <a id="LlInfo-exposed_hdrs"></a>`exposed_hdrs` |  A depset containing header files.    |
| <a id="LlInfo-exposed_includes"></a>`exposed_includes` |  A depset containing include paths.    |
| <a id="LlInfo-exposed_bmis"></a>`exposed_bmis` |  A depset containing precompiled module interfaces.    |
