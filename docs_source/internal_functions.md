<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="#archive_action"></a>

## archive_action

<pre>
archive_action(<a href="#archive_action-ctx">ctx</a>, <a href="#archive_action-object_files">object_files</a>, <a href="#archive_action-libraries">libraries</a>, <a href="#archive_action-toolchain_type">toolchain_type</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="archive_action-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="archive_action-object_files"></a>object_files |  <p align="center"> - </p>   |  none |
| <a id="archive_action-libraries"></a>libraries |  <p align="center"> - </p>   |  none |
| <a id="archive_action-toolchain_type"></a>toolchain_type |  <p align="center"> - </p>   |  none |


<a id="#compile_objects"></a>

## compile_objects

<pre>
compile_objects(<a href="#compile_objects-ctx">ctx</a>, <a href="#compile_objects-headers">headers</a>, <a href="#compile_objects-defines">defines</a>, <a href="#compile_objects-includes">includes</a>, <a href="#compile_objects-toolchain_type">toolchain_type</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="compile_objects-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="compile_objects-headers"></a>headers |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="compile_objects-defines"></a>defines |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="compile_objects-includes"></a>includes |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="compile_objects-toolchain_type"></a>toolchain_type |  <p align="center"> - </p>   |  <code>"//ll:toolchain_type"</code> |


<a id="#create_archive_library"></a>

## create_archive_library

<pre>
create_archive_library(<a href="#create_archive_library-ctx">ctx</a>, <a href="#create_archive_library-headers">headers</a>, <a href="#create_archive_library-libraries">libraries</a>, <a href="#create_archive_library-defines">defines</a>, <a href="#create_archive_library-includes">includes</a>, <a href="#create_archive_library-toolchain_type">toolchain_type</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="create_archive_library-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="create_archive_library-headers"></a>headers |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="create_archive_library-libraries"></a>libraries |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="create_archive_library-defines"></a>defines |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="create_archive_library-includes"></a>includes |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="create_archive_library-toolchain_type"></a>toolchain_type |  <p align="center"> - </p>   |  <code>"//ll:toolchain_type"</code> |


<a id="#create_compile_inputs"></a>

## create_compile_inputs

<pre>
create_compile_inputs(<a href="#create_compile_inputs-ctx">ctx</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="create_compile_inputs-ctx"></a>ctx |  <p align="center"> - </p>   |  none |


<a id="#create_executable"></a>

## create_executable

<pre>
create_executable(<a href="#create_executable-ctx">ctx</a>, <a href="#create_executable-headers">headers</a>, <a href="#create_executable-libraries">libraries</a>, <a href="#create_executable-defines">defines</a>, <a href="#create_executable-includes">includes</a>, <a href="#create_executable-toolchain_type">toolchain_type</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="create_executable-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="create_executable-headers"></a>headers |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="create_executable-libraries"></a>libraries |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="create_executable-defines"></a>defines |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="create_executable-includes"></a>includes |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="create_executable-toolchain_type"></a>toolchain_type |  <p align="center"> - </p>   |  <code>"//ll:toolchain_type"</code> |


<a id="#expose_headers"></a>

## expose_headers

<pre>
expose_headers(<a href="#expose_headers-ctx">ctx</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="expose_headers-ctx"></a>ctx |  <p align="center"> - </p>   |  none |


<a id="#resolve_deps"></a>

## resolve_deps

<pre>
resolve_deps(<a href="#resolve_deps-ctx">ctx</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="resolve_deps-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
