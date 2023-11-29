# `//ll:inputs.bzl`

Action inputs for rules.

<a id="compilable_sources"></a>

## `compilable_sources`

<pre><code>compilable_sources(<a href="#compilable_sources-ctx">ctx</a>)</code></pre>


`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="compilable_sources-ctx"></a>`ctx` |  |


<a id="compile_object_inputs"></a>

## `compile_object_inputs`

<pre><code>compile_object_inputs(<a href="#compile_object_inputs-ctx">ctx</a>, <a href="#compile_object_inputs-in_file">in_file</a>, <a href="#compile_object_inputs-headers">headers</a>, <a href="#compile_object_inputs-interfaces">interfaces</a>)</code></pre>
Collect all inputs for a compile action.

Takes files from the arguments and adds files from the `srcs` and `data`
fields and various toolchain dependencies.


`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="compile_object_inputs-ctx"></a>`ctx` | The rule context.  |
| <a id="compile_object_inputs-in_file"></a>`in_file` | The input file.  |
| <a id="compile_object_inputs-headers"></a>`headers` | A `depset` of headers.  |
| <a id="compile_object_inputs-interfaces"></a>`interfaces` | A `depset` of `(interface, name)` tuples.  |

`returns`

A `depset` of files.


<a id="create_archive_library_inputs"></a>

## `create_archive_library_inputs`

<pre><code>create_archive_library_inputs(<a href="#create_archive_library_inputs-ctx">ctx</a>, <a href="#create_archive_library_inputs-in_files">in_files</a>)</code></pre>


`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="create_archive_library_inputs-ctx"></a>`ctx` |  |
| <a id="create_archive_library_inputs-in_files"></a>`in_files` |  |


<a id="link_executable_inputs"></a>

## `link_executable_inputs`

<pre><code>link_executable_inputs(<a href="#link_executable_inputs-ctx">ctx</a>, <a href="#link_executable_inputs-in_files">in_files</a>)</code></pre>
Collect all inputs for link actions producing executables.

Apart from `in_files`, adds files from the `deps`, `libraries` and `data`
fields and various toolchain dependencies.


`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="link_executable_inputs-ctx"></a>`ctx` | The rule context.  |
| <a id="link_executable_inputs-in_files"></a>`in_files` | A list of files.  |

`returns`

A `depset` of files.


<a id="link_shared_object_inputs"></a>

## `link_shared_object_inputs`

<pre><code>link_shared_object_inputs(<a href="#link_shared_object_inputs-ctx">ctx</a>, <a href="#link_shared_object_inputs-in_files">in_files</a>)</code></pre>
Collect input files for link actions.

Adds files from the `deps` and `data` fields and various toolchain
dependencies.


`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="link_shared_object_inputs-ctx"></a>`ctx` | The rule context.  |
| <a id="link_shared_object_inputs-in_files"></a>`in_files` | A list of files.  |

`returns`

A `depset` of files.
