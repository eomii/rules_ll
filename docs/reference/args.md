# `//ll:args.bzl`

The functions that create `Args` for use in rule actions.


<a id="compile_object_args"></a>

## `compile_object_args`

<pre><code>compile_object_args(<a href="#compile_object_args-ctx">ctx</a>, <a href="#compile_object_args-in_file">in_file</a>, <a href="#compile_object_args-out_file">out_file</a>, <a href="#compile_object_args-cdf">cdf</a>, <a href="#compile_object_args-defines">defines</a>, <a href="#compile_object_args-includes">includes</a>, <a href="#compile_object_args-angled_includes">angled_includes</a>, <a href="#compile_object_args-bmis">bmis</a>)</code></pre>
Construct `Args` for compile actions.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="compile_object_args-ctx"></a>`ctx` | The rule context.  |
| <a id="compile_object_args-in_file"></a>`in_file` | The input file to compile.  |
| <a id="compile_object_args-out_file"></a>`out_file` | The output file.  |
| <a id="compile_object_args-cdf"></a>`cdf` | A file to store the compilation database fragment.  |
| <a id="compile_object_args-defines"></a>`defines` | A <code>depset</code> of defines for the target. Added with <code>-D</code>.  |
| <a id="compile_object_args-includes"></a>`includes` | A <code>depset</code> of includes for the target. Added with <code>-iquote</code>.  |
| <a id="compile_object_args-angled_includes"></a>`angled_includes` | A <code>depset</code> of angled includes for the target. Added with <code>-I</code>.  |
| <a id="compile_object_args-bmis"></a>`bmis` | A <code>depset</code> of tuples <code>(interface, name)</code>, each consisting of a binary module interface <code>interface</code> and a module name <code>name</code>. Added in a scheme resembling <code>-fmodule-file=name=interface</code>.  |

`returns`

An `Args` object.


<a id="create_archive_library_args"></a>

## `create_archive_library_args`

<pre><code>create_archive_library_args(<a href="#create_archive_library_args-ctx">ctx</a>, <a href="#create_archive_library_args-in_files">in_files</a>, <a href="#create_archive_library_args-out_file">out_file</a>)</code></pre>
Construct `Args` for archive actions.

Uses `-cqL` for regular archiving and `-vqL` for debug builds.


`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="create_archive_library_args-ctx"></a>`ctx` | The rule context.  |
| <a id="create_archive_library_args-in_files"></a>`in_files` | A <code>depset</code> of input files.  |
| <a id="create_archive_library_args-out_file"></a>`out_file` | The output file.  |

`returns`

An `Args` object.


<a id="link_executable_args"></a>

## `link_executable_args`

<pre><code>link_executable_args(<a href="#link_executable_args-ctx">ctx</a>, <a href="#link_executable_args-in_files">in_files</a>, <a href="#link_executable_args-out_file">out_file</a>, <a href="#link_executable_args-mode">mode</a>)</code></pre>
Construct `Args` for link actions.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="link_executable_args-ctx"></a>`ctx` | The rule context.  |
| <a id="link_executable_args-in_files"></a>`in_files` | A <code>depset</code> of input files.  |
| <a id="link_executable_args-out_file"></a>`out_file` | The output file.  |
| <a id="link_executable_args-mode"></a>`mode` | Either <code>"executable"</code> or <code>"shared_object"</code>, depending on the desired output type.  |

`returns`

An `Args` object.


<a id="llvm_bindir_path"></a>

## `llvm_bindir_path`

<pre><code>llvm_bindir_path(<a href="#llvm_bindir_path-ctx">ctx</a>)</code></pre>


`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="llvm_bindir_path-ctx"></a>`ctx` |  |
