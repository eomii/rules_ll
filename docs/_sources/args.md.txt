<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# `//ll:args.bzl`

Convenience function for setting compile arguments.


<a id="#compile_object_args"></a>

## compile_object_args

<pre>
compile_object_args(<a href="#compile_object_args-ctx">ctx</a>, <a href="#compile_object_args-in_file">in_file</a>, <a href="#compile_object_args-out_file">out_file</a>, <a href="#compile_object_args-cdf">cdf</a>, <a href="#compile_object_args-headers">headers</a>, <a href="#compile_object_args-defines">defines</a>, <a href="#compile_object_args-includes">includes</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="compile_object_args-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="compile_object_args-in_file"></a>in_file |  <p align="center"> - </p>   |  none |
| <a id="compile_object_args-out_file"></a>out_file |  <p align="center"> - </p>   |  none |
| <a id="compile_object_args-cdf"></a>cdf |  <p align="center"> - </p>   |  none |
| <a id="compile_object_args-headers"></a>headers |  <p align="center"> - </p>   |  none |
| <a id="compile_object_args-defines"></a>defines |  <p align="center"> - </p>   |  none |
| <a id="compile_object_args-includes"></a>includes |  <p align="center"> - </p>   |  none |


<a id="#create_archive_library_args"></a>

## create_archive_library_args

<pre>
create_archive_library_args(<a href="#create_archive_library_args-ctx">ctx</a>, <a href="#create_archive_library_args-in_files">in_files</a>, <a href="#create_archive_library_args-out_file">out_file</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="create_archive_library_args-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="create_archive_library_args-in_files"></a>in_files |  <p align="center"> - </p>   |  none |
| <a id="create_archive_library_args-out_file"></a>out_file |  <p align="center"> - </p>   |  none |


<a id="#expose_headers_args"></a>

## expose_headers_args

<pre>
expose_headers_args(<a href="#expose_headers_args-ctx">ctx</a>, <a href="#expose_headers_args-in_file">in_file</a>, <a href="#expose_headers_args-out_file">out_file</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="expose_headers_args-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="expose_headers_args-in_file"></a>in_file |  <p align="center"> - </p>   |  none |
| <a id="expose_headers_args-out_file"></a>out_file |  <p align="center"> - </p>   |  none |


<a id="#link_bitcode_library_args"></a>

## link_bitcode_library_args

<pre>
link_bitcode_library_args(<a href="#link_bitcode_library_args-ctx">ctx</a>, <a href="#link_bitcode_library_args-in_files">in_files</a>, <a href="#link_bitcode_library_args-out_file">out_file</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="link_bitcode_library_args-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="link_bitcode_library_args-in_files"></a>in_files |  <p align="center"> - </p>   |  none |
| <a id="link_bitcode_library_args-out_file"></a>out_file |  <p align="center"> - </p>   |  none |


<a id="#link_executable_args"></a>

## link_executable_args

<pre>
link_executable_args(<a href="#link_executable_args-ctx">ctx</a>, <a href="#link_executable_args-in_files">in_files</a>, <a href="#link_executable_args-out_file">out_file</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="link_executable_args-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="link_executable_args-in_files"></a>in_files |  <p align="center"> - </p>   |  none |
| <a id="link_executable_args-out_file"></a>out_file |  <p align="center"> - </p>   |  none |


<a id="#llvm_target_directory_path"></a>

## llvm_target_directory_path

<pre>
llvm_target_directory_path(<a href="#llvm_target_directory_path-ctx">ctx</a>)
</pre>

Returns the path to the `llvm-project` build output directory.

The path looks like `bazel-out/{cpu}-{mode}/bin/external/llvm-project`.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="llvm_target_directory_path-ctx"></a>ctx |  The rule context.   |  none |

**RETURNS**

A string.
