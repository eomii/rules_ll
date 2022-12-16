# `//ll:actions.bzl`

Actions wiring up inputs, outputs and tools to emit output files.

Every function in this file effectively wraps `ctx.actions.run` or
`ctx.actions.run_shell`.


<a id="compile_object"></a>

## compile_object

<pre>
compile_object(<a href="#compile_object-ctx">ctx</a>, <a href="#compile_object-in_file">in_file</a>, <a href="#compile_object-headers">headers</a>, <a href="#compile_object-defines">defines</a>, <a href="#compile_object-includes">includes</a>, <a href="#compile_object-angled_includes">angled_includes</a>, <a href="#compile_object-bmis">bmis</a>, <a href="#compile_object-internal_bmis">internal_bmis</a>,
               <a href="#compile_object-toolchain_type">toolchain_type</a>)
</pre>


**PARAMETERS**

| Name  | Description |
| :---- | :---------- |
| <a id="compile_object-ctx"></a>`ctx` |  |
| <a id="compile_object-in_file"></a>`in_file` |  |
| <a id="compile_object-headers"></a>`headers` |  |
| <a id="compile_object-defines"></a>`defines` |  |
| <a id="compile_object-includes"></a>`includes` |  |
| <a id="compile_object-angled_includes"></a>`angled_includes` |  |
| <a id="compile_object-bmis"></a>`bmis` |  |
| <a id="compile_object-internal_bmis"></a>`internal_bmis` |  |
| <a id="compile_object-toolchain_type"></a>`toolchain_type` |  |


<a id="compile_objects"></a>

## compile_objects

<pre>
compile_objects(<a href="#compile_objects-ctx">ctx</a>, <a href="#compile_objects-headers">headers</a>, <a href="#compile_objects-defines">defines</a>, <a href="#compile_objects-includes">includes</a>, <a href="#compile_objects-angled_includes">angled_includes</a>, <a href="#compile_objects-bmis">bmis</a>, <a href="#compile_objects-internal_bmis">internal_bmis</a>,
                <a href="#compile_objects-toolchain_type">toolchain_type</a>)
</pre>


**PARAMETERS**

| Name  | Description |
| :---- | :---------- |
| <a id="compile_objects-ctx"></a>`ctx` |  |
| <a id="compile_objects-headers"></a>`headers` |  |
| <a id="compile_objects-defines"></a>`defines` |  |
| <a id="compile_objects-includes"></a>`includes` |  |
| <a id="compile_objects-angled_includes"></a>`angled_includes` |  |
| <a id="compile_objects-bmis"></a>`bmis` |  |
| <a id="compile_objects-internal_bmis"></a>`internal_bmis` |  |
| <a id="compile_objects-toolchain_type"></a>`toolchain_type` |  |


<a id="create_archive_library"></a>

## create_archive_library

<pre>
create_archive_library(<a href="#create_archive_library-ctx">ctx</a>, <a href="#create_archive_library-in_files">in_files</a>, <a href="#create_archive_library-toolchain_type">toolchain_type</a>)
</pre>


**PARAMETERS**

| Name  | Description |
| :---- | :---------- |
| <a id="create_archive_library-ctx"></a>`ctx` |  |
| <a id="create_archive_library-in_files"></a>`in_files` |  |
| <a id="create_archive_library-toolchain_type"></a>`toolchain_type` |  |


<a id="link_bitcode_library"></a>

## link_bitcode_library

<pre>
link_bitcode_library(<a href="#link_bitcode_library-ctx">ctx</a>, <a href="#link_bitcode_library-in_files">in_files</a>, <a href="#link_bitcode_library-toolchain_type">toolchain_type</a>)
</pre>


**PARAMETERS**

| Name  | Description |
| :---- | :---------- |
| <a id="link_bitcode_library-ctx"></a>`ctx` |  |
| <a id="link_bitcode_library-in_files"></a>`in_files` |  |
| <a id="link_bitcode_library-toolchain_type"></a>`toolchain_type` |  |


<a id="link_executable"></a>

## link_executable

<pre>
link_executable(<a href="#link_executable-ctx">ctx</a>, <a href="#link_executable-in_files">in_files</a>, <a href="#link_executable-toolchain_type">toolchain_type</a>)
</pre>


**PARAMETERS**

| Name  | Description |
| :---- | :---------- |
| <a id="link_executable-ctx"></a>`ctx` |  |
| <a id="link_executable-in_files"></a>`in_files` |  |
| <a id="link_executable-toolchain_type"></a>`toolchain_type` |  |


<a id="link_shared_object"></a>

## link_shared_object

<pre>
link_shared_object(<a href="#link_shared_object-ctx">ctx</a>, <a href="#link_shared_object-in_files">in_files</a>, <a href="#link_shared_object-toolchain_type">toolchain_type</a>)
</pre>


**PARAMETERS**

| Name  | Description |
| :---- | :---------- |
| <a id="link_shared_object-ctx"></a>`ctx` |  |
| <a id="link_shared_object-in_files"></a>`in_files` |  |
| <a id="link_shared_object-toolchain_type"></a>`toolchain_type` |  |


<a id="precompile_interface"></a>

## precompile_interface

<pre>
precompile_interface(<a href="#precompile_interface-ctx">ctx</a>, <a href="#precompile_interface-in_file">in_file</a>, <a href="#precompile_interface-headers">headers</a>, <a href="#precompile_interface-defines">defines</a>, <a href="#precompile_interface-includes">includes</a>, <a href="#precompile_interface-angled_includes">angled_includes</a>, <a href="#precompile_interface-bmis">bmis</a>,
                     <a href="#precompile_interface-toolchain_type">toolchain_type</a>)
</pre>


**PARAMETERS**

| Name  | Description |
| :---- | :---------- |
| <a id="precompile_interface-ctx"></a>`ctx` |  |
| <a id="precompile_interface-in_file"></a>`in_file` |  |
| <a id="precompile_interface-headers"></a>`headers` |  |
| <a id="precompile_interface-defines"></a>`defines` |  |
| <a id="precompile_interface-includes"></a>`includes` |  |
| <a id="precompile_interface-angled_includes"></a>`angled_includes` |  |
| <a id="precompile_interface-bmis"></a>`bmis` |  |
| <a id="precompile_interface-toolchain_type"></a>`toolchain_type` |  |


<a id="precompile_interfaces"></a>

## precompile_interfaces

<pre>
precompile_interfaces(<a href="#precompile_interfaces-ctx">ctx</a>, <a href="#precompile_interfaces-headers">headers</a>, <a href="#precompile_interfaces-defines">defines</a>, <a href="#precompile_interfaces-includes">includes</a>, <a href="#precompile_interfaces-angled_includes">angled_includes</a>, <a href="#precompile_interfaces-bmis">bmis</a>, <a href="#precompile_interfaces-toolchain_type">toolchain_type</a>,
                      <a href="#precompile_interfaces-binary">binary</a>)
</pre>


**PARAMETERS**

| Name  | Description |
| :---- | :---------- |
| <a id="precompile_interfaces-ctx"></a>`ctx` |  |
| <a id="precompile_interfaces-headers"></a>`headers` |  |
| <a id="precompile_interfaces-defines"></a>`defines` |  |
| <a id="precompile_interfaces-includes"></a>`includes` |  |
| <a id="precompile_interfaces-angled_includes"></a>`angled_includes` |  |
| <a id="precompile_interfaces-bmis"></a>`bmis` |  |
| <a id="precompile_interfaces-toolchain_type"></a>`toolchain_type` |  |
| <a id="precompile_interfaces-binary"></a>`binary` |  |
