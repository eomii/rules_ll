<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# `//ll:providers.bzl`

Providers used by `rules_ll`.


<a id="#LlCompilationDatabaseFragmentsInfo"></a>

## LlCompilationDatabaseFragmentsInfo

<pre>
LlCompilationDatabaseFragmentsInfo(<a href="#LlCompilationDatabaseFragmentsInfo-cdfs">cdfs</a>)
</pre>

Provider containing compilation database fragments.

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="LlCompilationDatabaseFragmentsInfo-cdfs"></a>cdfs |  A depset containing compilation database fragments.         Assembling the compilation database fragments into a         compile_commands.json file produces a compilation database for tools         like clang-tidy.    |


<a id="#LlCompilationDatabaseInfo"></a>

## LlCompilationDatabaseInfo

<pre>
LlCompilationDatabaseInfo(<a href="#LlCompilationDatabaseInfo-compilation_database">compilation_database</a>)
</pre>



**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="LlCompilationDatabaseInfo-compilation_database"></a>compilation_database |  A compile_commands.json file containing a         compilation database.    |


<a id="#LlInfo"></a>

## LlInfo

<pre>
LlInfo(<a href="#LlInfo-exposed_angled_includes">exposed_angled_includes</a>, <a href="#LlInfo-exposed_defines">exposed_defines</a>, <a href="#LlInfo-exposed_hdrs">exposed_hdrs</a>, <a href="#LlInfo-exposed_includes">exposed_includes</a>, <a href="#LlInfo-exposed_bmis">exposed_bmis</a>)
</pre>

Provider returned by ll targets.

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="LlInfo-exposed_angled_includes"></a>exposed_angled_includes |  A depset containing angled include paths.         These include paths are carried to direct dependents.    |
| <a id="LlInfo-exposed_defines"></a>exposed_defines |  A depset containing defines. These defines are         carried to direct dependents.    |
| <a id="LlInfo-exposed_hdrs"></a>exposed_hdrs |  A depset containing header files. These header files         are carried to direct dependents.    |
| <a id="LlInfo-exposed_includes"></a>exposed_includes |  A depset containing include paths. These include         paths are carried to direct dependents.    |
| <a id="LlInfo-exposed_bmis"></a>exposed_bmis |  A depset containing precompiled module interfaces.         These interfaces are carried to direct dependents.    |
