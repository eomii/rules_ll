# CUDA and HIP

Manually setting up toolchains for heterogeneous code can be tedious. `rules_ll`
fully automates these setups and lets you build heterogeneous targets with
minimal adjustments to your build files.

Only Nvidia GPUs are currently supported.

Full examples are available at [rules_ll/examples](https://github.com/eomii/rules_ll/tree/main/examples).

!!! warning

    This feature is still under heavy development. APIs will frequently change.

## Prerequisites

You do **not** need to install the CUDA Toolkit or HIP libraries manually to use
the heterogeneous toolchains - `rules_ll` does that for you. However, you **do**
need to install an Nvidia driver on the host system and since we bump CUDA
versions rather aggressively, that driver will need to be *very* recent.

## Example

Heterogeneous targets need to know about three things:

1. The framework that was used to write the code. This can currently be CUDA or
   HIP. In the future we will add OpenMP and SYCL.
2. The target architecture of the GPU. Currently only the `nvptx` target (Nvidia
   GPUs) is supported. In the future we will add `amdgpu` (for AMD GPUs) and
   `spirv` (for Intel GPUs).
3. The offloading device architecture of the GPU model (or models) for which to
   build the code. For Nvidia GPUs this is also known as *compute capability*. A
   list of Nvidia GPU models and their corresponding compute capabilities can be
   found [here](https://developer.nvidia.com/cuda-gpus).

`ll_library` and `ll_binary` have a `compilation_mode` attribute which follow
the scheme `<framework>_<target_arch>`:

| Framework | Target Architecture | `compilation_mode` |
| --------- | ------------------- | ------------------ |
| CUDA      | NVPTX               | `cuda_nvptx`       |
| HIP       | NVPTX               | `hip_nvptx`        |

`rules_ll` does not (yet) have custom attributes to handle offloading
architectures. They can be specified via an `--offload-arch` flag in the
`compile_flags` attribute instead.

If we now have some HIP code which we want to build for an Nvidia Titan V (which
has compute capability 7.0), we could declare our target like this:

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
compilation parallelism at the cost of an (often negligible) runtime performance
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

C++ modules do not work with heterogeneous code. This is unfortunate, since
heterogeneous compilation is one of the applications that would benefit from
modules the most.
