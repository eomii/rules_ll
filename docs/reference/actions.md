# `//ll:actions.bzl`

Actions wiring up inputs, outputs, and tools to emit output files.

Every function in this file effectively wraps `ctx.actions.run` or
`ctx.actions.run_shell`.

<a id="compile_object"></a>

## `compile_object`

<pre><code>compile_object(<a href="#compile_object-ctx">ctx</a>, <a href="#compile_object-in_file">in_file</a>, <a href="#compile_object-headers">headers</a>, <a href="#compile_object-defines">defines</a>, <a href="#compile_object-includes">includes</a>, <a href="#compile_object-angled_includes">angled_includes</a>, <a href="#compile_object-bmis">bmis</a>)</code></pre>
Create a compiled object.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="compile_object-ctx"></a>`ctx` | The rule context.  |
| <a id="compile_object-in_file"></a>`in_file` | The input file to compile.  |
| <a id="compile_object-headers"></a>`headers` | A `depset` of files made available to the compile action.  |
| <a id="compile_object-defines"></a>`defines` | A `depset` of defines passed to the compile action.  |
| <a id="compile_object-includes"></a>`includes` | A `depset` of includes passed to the compile action.  |
| <a id="compile_object-angled_includes"></a>`angled_includes` | A `depset` of angled includes passed to the compile action.  |
| <a id="compile_object-bmis"></a>`bmis` | A `depset` of tuples `(interface, name)`, each consisting of a binary module interface `interface` and a module name `name`.  |

`returns`

A tuple `(out_file, cdf)`, of an output file and a compilation database
  fragment.


<a id="compile_objects"></a>

## `compile_objects`

<pre><code>compile_objects(<a href="#compile_objects-ctx">ctx</a>, <a href="#compile_objects-headers">headers</a>, <a href="#compile_objects-defines">defines</a>, <a href="#compile_objects-includes">includes</a>, <a href="#compile_objects-angled_includes">angled_includes</a>, <a href="#compile_objects-bmis">bmis</a>, <a href="#compile_objects-internal_bmis">internal_bmis</a>)</code></pre>
Create compiled objects emitted by the rule.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="compile_objects-ctx"></a>`ctx` | The rule context.  |
| <a id="compile_objects-headers"></a>`headers` | A `depset` of files made available to compile actions.  |
| <a id="compile_objects-defines"></a>`defines` | A `depset` of defines passed to compile actions.  |
| <a id="compile_objects-includes"></a>`includes` | A `depset` of includes passed to compile actions.  |
| <a id="compile_objects-angled_includes"></a>`angled_includes` | A `depset` of angled includes passed to compile actions.  |
| <a id="compile_objects-bmis"></a>`bmis` | A `depset` of tuples `(interface, name)`, each consisting of a binary module interface `interface` and a module name `name`.  |
| <a id="compile_objects-internal_bmis"></a>`internal_bmis` | Like `bmis`, but can't see the files in `bmis` during compilation.  |

`returns`

A tuple `(out_files, cdfs)`, of output files and compilation database
  fragments.


<a id="create_archive_library"></a>

## `create_archive_library`

<pre><code>create_archive_library(<a href="#create_archive_library-ctx">ctx</a>, <a href="#create_archive_library-in_files">in_files</a>)</code></pre>
Create an archive action for an archive.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="create_archive_library-ctx"></a>`ctx` | The rule context.  |
| <a id="create_archive_library-in_files"></a>`in_files` | A `depset` of input files.  |

`returns`

An output file.


<a id="link_executable"></a>

## `link_executable`

<pre><code>link_executable(<a href="#link_executable-ctx">ctx</a>, <a href="#link_executable-in_files">in_files</a>)</code></pre>
Create a link action for an executable.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="link_executable-ctx"></a>`ctx` | The rule context.  |
| <a id="link_executable-in_files"></a>`in_files` | A `depset` of input files.  |

`returns`

An output file.


<a id="link_shared_object"></a>

## `link_shared_object`

<pre><code>link_shared_object(<a href="#link_shared_object-ctx">ctx</a>, <a href="#link_shared_object-in_files">in_files</a>)</code></pre>
Create a link action for a shared object.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="link_shared_object-ctx"></a>`ctx` | The rule context.  |
| <a id="link_shared_object-in_files"></a>`in_files` | A `depset` of input files.  |

`returns`

An output file.


<a id="precompile_interface"></a>

## `precompile_interface`

<pre><code>precompile_interface(<a href="#precompile_interface-ctx">ctx</a>, <a href="#precompile_interface-in_file">in_file</a>, <a href="#precompile_interface-headers">headers</a>, <a href="#precompile_interface-defines">defines</a>, <a href="#precompile_interface-includes">includes</a>, <a href="#precompile_interface-angled_includes">angled_includes</a>, <a href="#precompile_interface-bmis">bmis</a>)</code></pre>


`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="precompile_interface-ctx"></a>`ctx` |  |
| <a id="precompile_interface-in_file"></a>`in_file` |  |
| <a id="precompile_interface-headers"></a>`headers` |  |
| <a id="precompile_interface-defines"></a>`defines` |  |
| <a id="precompile_interface-includes"></a>`includes` |  |
| <a id="precompile_interface-angled_includes"></a>`angled_includes` |  |
| <a id="precompile_interface-bmis"></a>`bmis` |  |


<a id="precompile_interfaces"></a>

## `precompile_interfaces`

<pre><code>precompile_interfaces(<a href="#precompile_interfaces-ctx">ctx</a>, <a href="#precompile_interfaces-headers">headers</a>, <a href="#precompile_interfaces-defines">defines</a>, <a href="#precompile_interfaces-includes">includes</a>, <a href="#precompile_interfaces-angled_includes">angled_includes</a>, <a href="#precompile_interfaces-bmis">bmis</a>, <a href="#precompile_interfaces-precompile_exposed">precompile_exposed</a>)</code></pre>
Create precompiled module interfaces.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="precompile_interfaces-ctx"></a>`ctx` | The rule context.  |
| <a id="precompile_interfaces-headers"></a>`headers` | A `depset` of files made available to compile actions.  |
| <a id="precompile_interfaces-defines"></a>`defines` | A `depset` of defines passed to compile actions.  |
| <a id="precompile_interfaces-includes"></a>`includes` | A `depset` of includes passed to compile actions.  |
| <a id="precompile_interfaces-angled_includes"></a>`angled_includes` | A `depset` of angled includes passed to compile actions.  |
| <a id="precompile_interfaces-bmis"></a>`bmis` | A `depset` of tuples `(interface, name)`, each consisting of a binary module interface `interface` and a module name `name`.  |
| <a id="precompile_interfaces-precompile_exposed"></a>`precompile_exposed` | A `boolean` indicating whether to precompile exposed BMIs. Set to `True` for libraries and to `False` for binaries.  |

`returns`

A tuple `(internal_bmis, exposed_bmis, cdfs)`.
