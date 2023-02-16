# `//ll:resolve_rule_inputs.bzl`

Resolve the inputs to `ll_library` and `ll_binary` rules.


<a id="expand_includes"></a>

## `expand_includes`

<pre><code>expand_includes(<a href="#expand_includes-ctx">ctx</a>, <a href="#expand_includes-include_string">include_string</a>)</code></pre>
Prefixes `include_path` with the path to the workspace root.

If `include_path` starts with `$(GENERATED)`, prefixes with the`GENDIR`
path as well.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="expand_includes-ctx"></a>`ctx` |  |
| <a id="expand_includes-include_string"></a>`include_string` |  |


<a id="resolve_rule_inputs"></a>

## `resolve_rule_inputs`

<pre><code>resolve_rule_inputs(<a href="#resolve_rule_inputs-ctx">ctx</a>)</code></pre>


`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="resolve_rule_inputs-ctx"></a>`ctx` |  |
