"""# `//ll:inputs.bzl`

Action inputs for rules.
"""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

COMPILABLE_EXTENSIONS = [
    "c",
    "cl",
    "cpp",
    "cu",
    "S",
    "cc",
    "cxx",
    "cpp",
    "pcm",
]

def compilable_sources(ctx):
    return [
        src
        for src in ctx.files.srcs
        if src.extension in COMPILABLE_EXTENSIONS
    ]

#TODO: Documentation lacking.
def compile_object_inputs(
        ctx,
        in_file,
        headers,
        interfaces):
    """Collect all inputs for a compile action.

    Takes files from the arguments and adds files from the `srcs` and `data`
    fields and various toolchain dependencies.

    Args:
        ctx: The rule context.
        in_file: The input file.
        headers: A `depset` of headers.
        interfaces: A `depset` of `(interface, name)` tuples.

    Returns:
        A `depset` of files.
    """
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    # TODO: This variable name is misleading.
    interfaces = depset([file for file, _ in interfaces.to_list()])

    direct = (
        [in_file] +
        ctx.files.srcs +
        ctx.files.data +
        toolchain.builtin_includes
    )
    transitive = [headers, interfaces]

    if ctx.attr.depends_on_llvm:
        transitive.append(toolchain.llvm_project_sources)

    if config == "bootstrap":
        return depset(direct, transitive = transitive)

    direct += (
        toolchain.cpp_stdhdrs +
        toolchain.unwind_library +
        toolchain.cpp_abihdrs +
        toolchain.compiler_runtime
    )

    if config == "cpp":
        pass
    elif config == "omp_cpu":
        direct += toolchain.omp_header
    elif config == "cuda_nvptx":
        pass
    elif config == "hip_nvptx":
        direct += toolchain.hip_libraries
    elif config == "hip_amdgpu":
        direct += (
            toolchain.hip_libraries +
            toolchain.rocm_device_libs +
            [toolchain.hip_runtime]
        )
    elif config == "sycl_cpu":
        direct += toolchain.hipsycl_hdrs
    elif config == "sycl_cuda":
        direct += toolchain.hipsycl_hdrs
    else:
        fail("Cannot compile with this toolchain config: {}.".format(config))

    return depset(direct, transitive = transitive)

def create_archive_library_inputs(ctx, in_files):
    return depset(
        [
            file
            for file in in_files + ctx.files.deps
            if file.extension in ["o", "a"]
        ],
    )

def link_executable_inputs(ctx, in_files):
    """Collect all inputs for link actions producing executables.

    Apart from `in_files`, adds files from the `deps`, `libraries` and `data`
    fields and various toolchain dependencies.

    Args:
        ctx: The rule context.
        in_files: A list of files.

    Returns:
        A `depset` of files.
    """
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    direct = (
        in_files +
        ctx.files.deps +
        ctx.files.libraries +
        ctx.files.data
    )

    if config == "bootstrap":
        return depset(direct)

    direct += (
        toolchain.cpp_stdlib +
        toolchain.unwind_library +
        toolchain.cpp_abilib +
        toolchain.compiler_runtime
    )

    if ctx.attr.depends_on_llvm:
        direct += toolchain.llvm_project_artifacts

    if config == "cpp":
        pass
    elif config == "omp_cpu":
        direct += toolchain.libomp
    elif config == "cuda_nvptx":
        pass
    elif config in ["hip_nvptx", "hip_amdgpu"]:
        if config == "hip_amdgpu":
            direct.append(toolchain.hip_runtime)
        direct += toolchain.hip_libraries
    elif config == "sycl_cpu":
        direct += [
            toolchain.hipsycl_runtime,
            toolchain.hipsycl_omp_backend,
        ]
    elif config == "sycl_cuda":
        direct.append(toolchain.hipsycl_runtime)
        # toolchain.hipsycl_omp_backend,
        # toolchain.hipsycl_cuda_backend,

    else:
        fail("Cannot link with this toolchain.")

    return depset(direct)

def link_shared_object_inputs(ctx, in_files):
    """Collect input files for link actions.

    Adds files from the `deps` and `data` fields and various toolchain
    dependencies.

    Args:
        ctx: The rule context.
        in_files: A list of files.

    Returns:
        A `depset` of files.
    """
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    direct = (
        in_files +
        ctx.files.deps +
        ctx.files.data
    )

    if ctx.attr.depends_on_llvm:
        direct += toolchain.llvm_project_artifacts

    if config == "bootstrap":
        return depset(direct)

    direct += (
        toolchain.cpp_stdlib +
        toolchain.cpp_abilib +
        toolchain.unwind_library +
        toolchain.compiler_runtime
    )

    if config == "cpp":
        pass
    elif config == "cuda_nvptx":
        pass
    elif config in ["hip_nvptx", "hip_amdgpu"]:
        direct += (
            toolchain.hip_libraries
        )
    else:
        fail("Cannot link shared objects with this toolchain.")

    return depset(direct)
