# `//ll:providers.bzl`

Providers for the `ll_binary`, `ll_library` and `ll_compilation_database` rules.


<a id="LlCompilationDatabaseFragmentsInfo"></a>

## `LlCompilationDatabaseFragmentsInfo`

<pre><code>LlCompilationDatabaseFragmentsInfo(<a href="#LlCompilationDatabaseFragmentsInfo-cdfs">cdfs</a>)</code></pre>
Stores compilation database fragments.

`fields`


| Name  | Description |
| :------------- | :------------- |
| <a id="LlCompilationDatabaseFragmentsInfo-cdfs"></a>`cdfs` |  A <code>depset</code> of compilation database fragments.    |


<a id="LlCompilationDatabaseInfo"></a>

## `LlCompilationDatabaseInfo`

<pre><code>LlCompilationDatabaseInfo(<a href="#LlCompilationDatabaseInfo-compilation_database">compilation_database</a>)</code></pre>
Provider for a compilation database.

`fields`


| Name  | Description |
| :------------- | :------------- |
| <a id="LlCompilationDatabaseInfo-compilation_database"></a>`compilation_database` |  A <code>compile_commands.json</code> file.<br><br>        This file stores the compilation database.    |


<a id="LlInfo"></a>

## `LlInfo`

<pre><code>LlInfo(<a href="#LlInfo-exposed_angled_includes">exposed_angled_includes</a>, <a href="#LlInfo-exposed_defines">exposed_defines</a>, <a href="#LlInfo-exposed_hdrs">exposed_hdrs</a>, <a href="#LlInfo-exposed_includes">exposed_includes</a>, <a href="#LlInfo-exposed_bmis">exposed_bmis</a>)</code></pre>
The default provider returned by an `ll_*` target.

`fields`


| Name  | Description |
| :------------- | :------------- |
| <a id="LlInfo-exposed_angled_includes"></a>`exposed_angled_includes` |  A <code>depset</code> of angled includes.    |
| <a id="LlInfo-exposed_defines"></a>`exposed_defines` |  A <code>depset</code> of defines.    |
| <a id="LlInfo-exposed_hdrs"></a>`exposed_hdrs` |  A <code>depset</code> of header files.    |
| <a id="LlInfo-exposed_includes"></a>`exposed_includes` |  A <code>depset</code> of includes.    |
| <a id="LlInfo-exposed_bmis"></a>`exposed_bmis` |  A <code>depset</code> of BMIs.    |
