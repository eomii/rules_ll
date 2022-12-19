# CUDA and HIP

`rules_ll` fully automates the setups for heterogeneous toolchains and lets you
build heterogeneous targets with minimal adjustments to your build files.

At the moment `rules_ll` supports Nvidia GPUs.

You can find full examples at [rules_ll/examples](https://github.com/eomii/rules_ll/tree/main/examples).

!!! warning

    This feature is still under heavy development. APIs will frequently change.

## Prerequisites

You do **not** need to install the CUDA Toolkit or HIP libraries manually to use
the heterogeneous toolchains - `rules_ll` does that for you. You **do** need to
install an Nvidia driver on the host system though. Since `rules_ll` bumps CUDA
versions rather aggressively, make sure to use the latest drivers.

## Example

Heterogeneous targets need to know about three things:

1. The framework you use to write the code. At the moment, `rules_ll` supports
   CUDA and HIP. OpenMP and SYCL coming soon.
2. The GPU target architecture. At the moment, `rules_ll` supports the `nvptx`
   for Nvidia GPUs. Support for `amdgpu` (AMD GPUs) and `spirv` (Intel GPUs)
   coming soon.
3. The offloading device architectures of the GPU models for which to build the
   code. For Nvidia GPUs also known as *compute capability*. You can find a list
   of Nvidia GPU models and their corresponding compute capabilities
   [here](https://developer.nvidia.com/cuda-gpus).

`ll_library` and `ll_binary` have a `compilation_mode` attribute which follow
the scheme `<framework>_<target_arch>`:

| Framework | Target Architecture | `compilation_mode` |
| --------- | ------------------- | ------------------ |
| CUDA      | NVPTX               | `cuda_nvptx`       |
| HIP       | NVPTX               | `hip_nvptx`        |

The current `rules_ll` API doesn't have custom attributes to handle offloading
architectures. Specify this via an `--offload-arch` flag in the `compile_flags`
attribute instead.

If you have some HIP code which you want to build for an Nvidia Titan V (which
has compute capability 7.0), you could declare your target like this:

```python title="BUILD.bazel" hl_lines="4 6"
ll_binary(
   name = "my_hip_nvidia_target",
   srcs = ["main.cpp"],
   compilation_mode = "hip_nvptx",
   compile_flags = [
      "--offload-arch=sm_70",
   ],
)
```

## Relocatable device code

To build [relocatable device code](https://developer.nvidia.com/blog/separate-compilation-linking-cuda-device-code/),
add the `-fgpu-rdc` flag to `compile_flags`. This lets you split device code
into separate files for cleaner repository layout and a higher degree of
compilation parallelism at the cost of an often negligible runtime performance
penalty:

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
