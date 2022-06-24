<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# `//ll:actions.bzl`

Actions wiring up inputs, outputs and tools to emit output files.

Every function in this file effectively wraps `ctx.actions.run` or
`ctx.actions.run_shell`.


<a id="#compile_object"></a>

## compile_object

<pre>
compile_object(<a href="#compile_object-ctx">ctx</a>, <a href="#compile_object-in_file">in_file</a>, <a href="#compile_object-headers">headers</a>, <a href="#compile_object-defines">defines</a>, <a href="#compile_object-includes">includes</a>, <a href="#compile_object-angled_includes">angled_includes</a>, <a href="#compile_object-toolchain_type">toolchain_type</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="compile_object-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="compile_object-in_file"></a>in_file |  <p align="center"> - </p>   |  none |
| <a id="compile_object-headers"></a>headers |  <p align="center"> - </p>   |  none |
| <a id="compile_object-defines"></a>defines |  <p align="center"> - </p>   |  none |
| <a id="compile_object-includes"></a>includes |  <p align="center"> - </p>   |  none |
| <a id="compile_object-angled_includes"></a>angled_includes |  <p align="center"> - </p>   |  none |
| <a id="compile_object-toolchain_type"></a>toolchain_type |  <p align="center"> - </p>   |  none |


<a id="#compile_objects"></a>

## compile_objects

<pre>
compile_objects(<a href="#compile_objects-ctx">ctx</a>, <a href="#compile_objects-headers">headers</a>, <a href="#compile_objects-defines">defines</a>, <a href="#compile_objects-includes">includes</a>, <a href="#compile_objects-angled_includes">angled_includes</a>, <a href="#compile_objects-toolchain_type">toolchain_type</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="compile_objects-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="compile_objects-headers"></a>headers |  <p align="center"> - </p>   |  none |
| <a id="compile_objects-defines"></a>defines |  <p align="center"> - </p>   |  none |
| <a id="compile_objects-includes"></a>includes |  <p align="center"> - </p>   |  none |
| <a id="compile_objects-angled_includes"></a>angled_includes |  <p align="center"> - </p>   |  none |
| <a id="compile_objects-toolchain_type"></a>toolchain_type |  <p align="center"> - </p>   |  none |


<a id="#create_archive_library"></a>

## create_archive_library

<pre>
create_archive_library(<a href="#create_archive_library-ctx">ctx</a>, <a href="#create_archive_library-in_files">in_files</a>, <a href="#create_archive_library-toolchain_type">toolchain_type</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="create_archive_library-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="create_archive_library-in_files"></a>in_files |  <p align="center"> - </p>   |  none |
| <a id="create_archive_library-toolchain_type"></a>toolchain_type |  <p align="center"> - </p>   |  none |


<a id="#expose_headers"></a>

## expose_headers

<pre>
expose_headers(<a href="#expose_headers-ctx">ctx</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="expose_headers-ctx"></a>ctx |  <p align="center"> - </p>   |  none |


<a id="#link_bitcode_library"></a>

## link_bitcode_library

<pre>
link_bitcode_library(<a href="#link_bitcode_library-ctx">ctx</a>, <a href="#link_bitcode_library-in_files">in_files</a>, <a href="#link_bitcode_library-toolchain_type">toolchain_type</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="link_bitcode_library-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="link_bitcode_library-in_files"></a>in_files |  <p align="center"> - </p>   |  none |
| <a id="link_bitcode_library-toolchain_type"></a>toolchain_type |  <p align="center"> - </p>   |  none |


<a id="#link_executable"></a>

## link_executable

<pre>
link_executable(<a href="#link_executable-ctx">ctx</a>, <a href="#link_executable-in_files">in_files</a>, <a href="#link_executable-toolchain_type">toolchain_type</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="link_executable-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="link_executable-in_files"></a>in_files |  <p align="center"> - </p>   |  none |
| <a id="link_executable-toolchain_type"></a>toolchain_type |  <p align="center"> - </p>   |  none |


<a id="#link_shared_object"></a>

## link_shared_object

<pre>
link_shared_object(<a href="#link_shared_object-ctx">ctx</a>, <a href="#link_shared_object-in_files">in_files</a>, <a href="#link_shared_object-toolchain_type">toolchain_type</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="link_shared_object-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="link_shared_object-in_files"></a>in_files |  <p align="center"> - </p>   |  none |
| <a id="link_shared_object-toolchain_type"></a>toolchain_type |  <p align="center"> - </p>   |  none |
