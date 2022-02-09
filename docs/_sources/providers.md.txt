<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="#LlInfo"></a>

## LlInfo

<pre>
LlInfo(<a href="#LlInfo-exported_headers">exported_headers</a>, <a href="#LlInfo-transitive_headers">transitive_headers</a>, <a href="#LlInfo-libraries">libraries</a>, <a href="#LlInfo-transitive_defines">transitive_defines</a>, <a href="#LlInfo-transitive_includes">transitive_includes</a>)
</pre>

Provider returned by ll targets.

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="LlInfo-exported_headers"></a>exported_headers |  A directory containing exported header files.    |
| <a id="LlInfo-transitive_headers"></a>transitive_headers |  A depset containing header files. These header files are carried to all depending targets.    |
| <a id="LlInfo-libraries"></a>libraries |  A depset containing object files.    |
| <a id="LlInfo-transitive_defines"></a>transitive_defines |  A depset containing defines. These defines are carried to all depending targets.    |
| <a id="LlInfo-transitive_includes"></a>transitive_includes |  A depset containing include paths. These include paths are carried to all depending targets.    |
