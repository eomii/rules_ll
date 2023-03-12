# `//ll:outputs.bzl`

Action outputs.


<a id="compile_object_outputs"></a>

## `compile_object_outputs`

<pre><code>compile_object_outputs(<a href="#compile_object_outputs-ctx">ctx</a>, <a href="#compile_object_outputs-in_file">in_file</a>)</code></pre>
Given a compilable file, return an output name for the compiled object.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="compile_object_outputs-ctx"></a>`ctx` | The rule context.  |
| <a id="compile_object_outputs-in_file"></a>`in_file` | A <code>file</code>.  |

`returns`

A tuple `(out_file, cdf)`. Outputs end with `.o`/`.cdf` or
  `.interface.o`/`.interface.cdf`, if `in_file` has a `.pcm` extension.


<a id="create_archive_library_outputs"></a>

## `create_archive_library_outputs`

<pre><code>create_archive_library_outputs(<a href="#create_archive_library_outputs-ctx">ctx</a>)</code></pre>
For a label `filename` return a file `filename.a`.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="create_archive_library_outputs-ctx"></a>`ctx` |  |


<a id="link_executable_outputs"></a>

## `link_executable_outputs`

<pre><code>link_executable_outputs(<a href="#link_executable_outputs-ctx">ctx</a>)</code></pre>
For a label `filename` return a file of the same name.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="link_executable_outputs-ctx"></a>`ctx` |  |


<a id="link_shared_object_outputs"></a>

## `link_shared_object_outputs`

<pre><code>link_shared_object_outputs(<a href="#link_shared_object_outputs-ctx">ctx</a>)</code></pre>
For a label `filename` return a file `filename.so`.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="link_shared_object_outputs-ctx"></a>`ctx` |  |


<a id="ll_artifact"></a>

## `ll_artifact`

<pre><code>ll_artifact(<a href="#ll_artifact-ctx">ctx</a>, <a href="#ll_artifact-filename">filename</a>)</code></pre>
Return a string of the form `"{ctx.label.name}/filename"`.

Encapsulate intermediary build artifacts to avoid name clashes for files of
the same name built by targets in the same build invocation.


`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="ll_artifact-ctx"></a>`ctx` | The build context.  |
| <a id="ll_artifact-filename"></a>`filename` |  defaults to `None`.<br><br>An optional string representing a filename. If omitted, creates a path of the form <code>"{ctx.label.name}"</code>.  |


<a id="precompile_interface_outputs"></a>

## `precompile_interface_outputs`

<pre><code>precompile_interface_outputs(<a href="#precompile_interface_outputs-ctx">ctx</a>, <a href="#precompile_interface_outputs-in_file">in_file</a>)</code></pre>
Given a file `f.cppm` return files `f.pcm` and `f.pcm.cdf`.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="precompile_interface_outputs-ctx"></a>`ctx` | The rule context.  |
| <a id="precompile_interface_outputs-in_file"></a>`in_file` | A <code>file</code>.  |

`returns`

A tuple `(out_file, cdf)`.
