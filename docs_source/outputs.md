<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# `//ll:outputs.bzl`

Action outputs.


<a id="#compile_object_outputs"></a>

## compile_object_outputs

<pre>
compile_object_outputs(<a href="#compile_object_outputs-ctx">ctx</a>, <a href="#compile_object_outputs-in_file">in_file</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="compile_object_outputs-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="compile_object_outputs-in_file"></a>in_file |  <p align="center"> - </p>   |  none |


<a id="#create_archive_library_outputs"></a>

## create_archive_library_outputs

<pre>
create_archive_library_outputs(<a href="#create_archive_library_outputs-ctx">ctx</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="create_archive_library_outputs-ctx"></a>ctx |  <p align="center"> - </p>   |  none |


<a id="#link_bitcode_library_outputs"></a>

## link_bitcode_library_outputs

<pre>
link_bitcode_library_outputs(<a href="#link_bitcode_library_outputs-ctx">ctx</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="link_bitcode_library_outputs-ctx"></a>ctx |  <p align="center"> - </p>   |  none |


<a id="#link_executable_outputs"></a>

## link_executable_outputs

<pre>
link_executable_outputs(<a href="#link_executable_outputs-ctx">ctx</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="link_executable_outputs-ctx"></a>ctx |  <p align="center"> - </p>   |  none |


<a id="#link_shared_object_outputs"></a>

## link_shared_object_outputs

<pre>
link_shared_object_outputs(<a href="#link_shared_object_outputs-ctx">ctx</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="link_shared_object_outputs-ctx"></a>ctx |  <p align="center"> - </p>   |  none |


<a id="#ll_artifact"></a>

## ll_artifact

<pre>
ll_artifact(<a href="#ll_artifact-ctx">ctx</a>, <a href="#ll_artifact-filename">filename</a>)
</pre>

Returns a string like "<ctx.label.name>/filename"

We use this method to encapsulate intermediary build artifacts so that we
don't get name clashes for files of the same name built by targets in the
same build invocation.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="ll_artifact-ctx"></a>ctx |  The build context.   |  none |
| <a id="ll_artifact-filename"></a>filename |  An optional string representing a filename. If omitted, only creates a path like "&lt;ctx.label.name&gt;".   |  <code>None</code> |


<a id="#precompile_interface_outputs"></a>

## precompile_interface_outputs

<pre>
precompile_interface_outputs(<a href="#precompile_interface_outputs-ctx">ctx</a>, <a href="#precompile_interface_outputs-in_file">in_file</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="precompile_interface_outputs-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="precompile_interface_outputs-in_file"></a>in_file |  <p align="center"> - </p>   |  none |
