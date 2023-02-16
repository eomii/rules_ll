# `//ll:driver.bzl`

Select the C or C++ driver for compile actions.


<a id="compiler_driver"></a>

## `compiler_driver`

<pre><code>compiler_driver(<a href="#compiler_driver-ctx">ctx</a>, <a href="#compiler_driver-in_file">in_file</a>)</code></pre>
Return either the C or C++ driver, depending on the input file extension.

`parameters`

| Name  | Description |
| :---- | :---------- |
| <a id="compiler_driver-ctx"></a>`ctx` | The rule context.  |
| <a id="compiler_driver-in_file"></a>`in_file` | A file.  |

`returns`

The C driver if `in_file` ends in `.c`. The C++ driver otherwise.
