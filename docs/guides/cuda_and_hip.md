# CUDA and HIP

`rules_ll` fully automates the setups for heterogeneous toolchains. This lets
you build CUDA and HIP code with minimal adjustments to your build files.

At the moment `rules_ll` supports Nvidia and AMD GPUs.

You can find examples at [`rules_ll/examples`](https://github.com/eomii/rules_ll/tree/main/examples).

<!-- markdownlint-disable code-block-style -->
!!! warning

    This feature is still under heavy development. APIs will frequently change.
<!-- markdownlint-enable code-block-style -->

## Prerequisites

You do **not** need to install the CUDA Toolkit or the ROCm stack to use the
heterogeneous toolchains - `rules_ll` does that for you. You **do** need to
install an Nvidia or AMD driver on the system that runs the executables though.
Since `rules_ll` bumps versions rather aggressively make sure to use the latest
drivers.

You don't need a GPU on the machine that builds the heterogeneous targets.

## Example

Heterogeneous targets need to know about three things:

1. The framework that you used to write your code. At the moment you can use
   CUDA and HIP. OpenMP and SYCL planned for future releases.
2. The GPU target architecture. At the moment, `rules_ll` supports `nvptx` for
   Nvidia GPUs and `amdgpu` for AMD GPUs. `spirv` for Intel GPUs planned for
   future releases.
3. The offload architectures of the target GPU models. Also known as *compute
   capability*. You can find a list of Nvidia GPU models and corresponding
   compute capabilities [here](https://developer.nvidia.com/cuda-gpus) and a
   list of AMD GPU models and corresponding compute capabilities [here](https://llvm.org/docs/AMDGPUUsage.html#processors).

The `ll_library` and `ll_binary` rules have a `compilation_mode` attribute which
you can set according to the scheme `<framework>_<target_arch>`:

| Framework | Target Architecture | `compilation_mode` |
| --------- | ------------------- | ------------------ |
| CUDA      | NVPTX               | `cuda_nvptx`       |
| HIP       | NVPTX               | `hip_nvptx`        |
| HIP       | AMDGPU              | `hip_amdgpu`       |

To offload to specific architectures, add the corresponding architecture to
`compile_flags` with the `--offload-arch` flag.

| Target Architecture | Supported `offload-arch` | Example `compile_flags`  |
| ------------------- | ------------------------ | ------------------------ |
| NVPTX               | 5.2 to 9.0               | `--offload-arch=sm_52`   |
| AMDGPU              | GFX8 to GFX11            | `--offload-arch=gfx1103` |

For instance, to build HIP code for an Nvidia Titan V with compute capability
7.0 you could write a target like this:

```python title="BUILD.bazel" hl_lines="6 8"
load("@rules_ll//ll:defs.bzl", "ll_binary")

ll_binary(
   name = "my_hip_nvptx_target",
   srcs = ["main.cpp"],
   compilation_mode = "hip_nvptx",
   compile_flags = [
      "--offload-arch=sm_70",
   ],
)
```

For an AMD RX 7900 XT with compute capability GFX11 you could write a target
like this:

```python title="BUILD.bazel" hl_lines="6 8"
load("@rules_ll//ll:defs.bzl", "ll_binary")

ll_binary(
    name = "my_hip_amdgpu_target",
    srcs = ["main.cpp"],
    compilation_mode = "hip_amdgpu",
    compile_flags = [
        "--offload-arch=gfx1100",
    ],
)
```

## Targeting all available architectures

Use the `OFFLOAD_ALL_NVPTX` shortcut to target all supported NVPTX offload
architectures:

```python title="BUILD.bazel" hl_lines="7"
load("@rules_ll//ll:defs.bzl", "OFFLOAD_ALL_NVPTX", "ll_binary")

ll_binary(
   name = "my_hip_nvptx_target",
   srcs = ["main.cpp"],
   compilation_mode = "hip_nvptx",
   compile_flags = OFFLOAD_ALL_NVPTX,
)
```

Use the `OFFLOAD_ALL_AMDGPU` shortcut to target all supported AMDGPU offload
architectures:

```python title="BUILD.bazel" hl_lines="7"
load("@rules_ll//ll:defs.bzl", "OFFLOAD_ALL_AMDGPU", "ll_binary")

ll_binary(
   name = "my_hip_amdgpu_target",
   srcs = ["main.cpp"],
   compilation_mode = "hip_amdgpu",
   compile_flags = OFFLOAD_ALL_AMDGPU,
)
```

<!-- vale Microsoft.Headings = NO -->

## Relocatable device code

<!-- vale Microsoft.Headings = YES -->

To build [relocatable device code](https://developer.nvidia.com/blog/separate-compilation-linking-cuda-device-code/),
add `-fgpu-rdc` to `compile_flags`. This lets you split device code into
different files for a cleaner repository layout. Note that this comes at the
cost of an often negligible runtime performance penalty:

```python title="BUILD.bazel" hl_lines="8 18"
ll_library(
   name = "my_device_code",
   srcs = ["device_code.cpp"],
   exposed_hdrs = ["device_code_declaration.hpp"],
   compilation_mode = "hip_nvptx",
   compile_flags = [
      "--offload-arch=sm_70",
      "-fgpu-rdc",
   ],
)

ll_binary(
   name = "my_hip_nvidia_target",
   srcs = ["main.cpp"],
   compilation_mode = "hip_nvptx",
   compile_flags = [
      "--offload-arch=sm_70",
      "-fgpu-rdc",
   ],
   deps = [
      ":my_device_code",
   ],
)
```

## Caveats

C++ modules don't work with heterogeneous code yet.

Targeting both NVPTX and AMDGPU in a single codebase requires separate targets,
making build files somewhat verbose. `rules_ll` plans to change the API for
heterogeneous compilation to use platforms so that `select` becomes viable for
such use cases.

Confusingly, the `compilation_mode` flag in `ll_*` targets has the name as the
unrelated `--compilation_mode` flag for Bazel. Planned to change in the future.
