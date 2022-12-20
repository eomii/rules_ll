# CUDA and HIP

`rules_ll` fully automates the setups for heterogeneous toolchains. This lets
you build CUDA and HIP code with minimal adjustments to your build files.

At the moment `rules_ll` supports Nvidia GPUs.

You can find full examples at [`rules_ll/examples`](https://github.com/eomii/rules_ll/tree/main/examples).

!!! warning

    This feature is still under heavy development. APIs will frequently change.

## Prerequisites

You do **not** need to install the CUDA Toolkit or HIP libraries to use the
heterogeneous toolchains - `rules_ll` does that for you. You **do** need to
install an Nvidia driver on the host system though. Since `rules_ll` bumps CUDA
versions rather aggressively, that you use the latest drivers.

## Example

Heterogeneous targets need to know about three things:

1. The framework that you used to write your code. At the moment you can use
   CUDA or HIP. OpenMP and SYCL coming soon.
2. The GPU target architecture. At the moment, `rules_ll` supports `nvptx` for
   Nvidia GPUs. Support for `amdgpu` (AMD GPUs) and `spirv` (Intel GPUs) coming
   soon.
3. The offload architectures of the target GPU models. For Nvidia GPUs also
   known as *compute capability*. Find a list of Nvidia GPU models and
   corresponding compute capabilities [here](https://developer.nvidia.com/cuda-gpus).

The `ll_library` and `ll_binary` rules have a `compilation_mode` attribute which
you can set according to the scheme `<framework>_<target_arch>`:

| Framework | Target Architecture | `compilation_mode` |
| --------- | ------------------- | ------------------ |
| CUDA      | NVPTX               | `cuda_nvptx`       |
| HIP       | NVPTX               | `hip_nvptx`        |

`rules_ll` doesn't have custom attributes to handle offloading architectures.
Add an `--offload-arch` flag to `compile_flags` instead.

For instance, to build HIP code for an Nvidia Titan V (which has compute
capability 7.0), you could use a target like this:

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
