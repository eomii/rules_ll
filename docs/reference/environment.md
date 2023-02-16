# `//ll:environment.bzl`

Environment variables for use in compile and link actions.


<a id="compile_object_environment"></a>

## `compile_object_environment`

<pre><code>compile_object_environment(<a href="#compile_object_environment-ctx">ctx</a>)</code></pre>
Set environment variables for compile and link actions.

For end users this depends on `compilation_mode` in the `ll_library` and
`ll_binary` rules.


`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="compile_object_environment-ctx"></a>`ctx` | The rule context.  |

`returns`

A `dict` for use in the `environment` of an action.
