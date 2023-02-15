"""# `//ll:inputs.bzl`

Action inputs for rules.
"""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

COMPILABLE_EXTENSIONS = [
    "ll",
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

def compile_object_inputs(
        ctx,
        in_file,
        headers,
        interfaces,
        local_interfaces,
        toolchain_type):
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value

    interfaces = depset([file for file, _ in interfaces.to_list()])
    local_interfaces = [file for file, _ in local_interfaces]

    direct = (
        [in_file] +
        local_interfaces +
        ctx.files.srcs +
        ctx.files.data +
        ctx.toolchains[toolchain_type].builtin_includes
    )
    transitive = [headers, interfaces]

    if ctx.attr.depends_on_llvm:
        transitive.append(ctx.toolchains[toolchain_type].llvm_project_sources)

    if config == "bootstrap":
        return depset(direct, transitive = transitive)

    direct += (
        ctx.toolchains[toolchain_type].cpp_stdhdrs +
        ctx.toolchains[toolchain_type].unwind_library +
        ctx.toolchains[toolchain_type].cpp_abihdrs +
        ctx.toolchains[toolchain_type].compiler_runtime
    )

    if config == "cpp":
        pass
    elif config == "omp_cpu":
        direct += (
            ctx.toolchains[toolchain_type].omp_header
        )
    elif config == "cuda_nvptx":
        direct += (
            ctx.toolchains[toolchain_type].cuda_toolkit
        )
    elif config == "hip_nvptx":
        direct += (
            ctx.toolchains[toolchain_type].cuda_toolkit +
            ctx.toolchains[toolchain_type].hip_libraries
        )
    elif config == "sycl_cpu":
        direct += ctx.toolchains[toolchain_type].hipsycl_hdrs
    elif config == "sycl_cuda":
        direct += (
            ctx.toolchains[toolchain_type].cuda_toolkit +
            ctx.toolchains[toolchain_type].hipsycl_hdrs
        )
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

def link_executable_inputs(ctx, in_files, toolchain_type):
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value

    direct = (
        in_files +
        ctx.files.deps +
        ctx.files.libraries +
        ctx.files.data
    )

    if config == "bootstrap":
        return depset(direct)

    direct += (
        ctx.toolchains[toolchain_type].cpp_stdlib +
        ctx.toolchains[toolchain_type].unwind_library +
        ctx.toolchains[toolchain_type].cpp_abilib +
        ctx.toolchains[toolchain_type].compiler_runtime
    )

    if ctx.attr.depends_on_llvm:
        direct += ctx.toolchains[toolchain_type].llvm_project_artifacts

    if config == "cpp":
        pass
    elif config == "omp_cpu":
        direct += (
            ctx.toolchains[toolchain_type].libomp
        )
    elif config == "cuda_nvptx":
        direct += (
            ctx.toolchains[toolchain_type].cuda_toolkit +
            [ctx.toolchains[toolchain_type].cuda_libdir] +
            [ctx.toolchains[toolchain_type].cuda_bindir] +
            [ctx.toolchains[toolchain_type].cuda_nvvm]
        )

    elif config == "hip_nvptx":
        direct += (
            ctx.toolchains[toolchain_type].cuda_toolkit +
            [ctx.toolchains[toolchain_type].cuda_libdir] +
            [ctx.toolchains[toolchain_type].cuda_bindir] +
            [ctx.toolchains[toolchain_type].cuda_nvvm] +
            ctx.toolchains[toolchain_type].hip_libraries
        )
    elif config == "sycl_cpu":
        direct += [
            ctx.toolchains[toolchain_type].hipsycl_runtime,
            ctx.toolchains[toolchain_type].hipsycl_omp_backend,
        ]
    elif config == "sycl_cuda":
        direct += (
            ctx.toolchains[toolchain_type].cuda_toolkit +
            [
                ctx.toolchains[toolchain_type].cuda_bindir,
                ctx.toolchains[toolchain_type].cuda_libdir,
                ctx.toolchains[toolchain_type].cuda_nvvm,
                ctx.toolchains[toolchain_type].hipsycl_runtime,
                # ctx.toolchains[toolchain_type].hipsycl_omp_backend,
                # ctx.toolchains[toolchain_type].hipsycl_cuda_backend,
            ]
        )
    else:
        fail("Cannot link with this toolchain.")

    return depset(direct)

def link_bitcode_library_inputs(ctx, in_files):
    if "//ll:toolchain_type" in ctx.toolchains:
        return depset(in_files + ctx.files.deps + ctx.files.bitcode_libraries)
    else:
        fail("Can only link bitcode when using \"//ll:toolchain_type\".")

def link_shared_object_inputs(ctx, in_files, toolchain_type):
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value

    direct = (
        in_files +
        ctx.files.deps +
        ctx.files.data
    )

    if ctx.attr.depends_on_llvm:
        direct += ctx.toolchains["//ll:toolchain_type"].llvm_project_artifacts

    if config == "bootstrap":
        return depset(direct)

    direct += (
        ctx.toolchains[toolchain_type].cpp_stdlib +
        ctx.toolchains[toolchain_type].cpp_abilib +
        ctx.toolchains[toolchain_type].unwind_library +
        ctx.toolchains[toolchain_type].compiler_runtime
    )

    if config == "cpp":
        pass
    elif config == "cuda_nvptx":
        direct += (
            ctx.toolchains[toolchain_type].cuda_toolkit +
            [ctx.toolchains[toolchain_type].cuda_libdir] +
            [ctx.toolchains[toolchain_type].cuda_nvvm]
        )

    elif config == "hip_nvptx":
        direct += (
            ctx.toolchains[toolchain_type].cuda_toolkit +
            [ctx.toolchains[toolchain_type].cuda_libdir] +
            [ctx.toolchains[toolchain_type].cuda_nvvm] +
            ctx.toolchains[toolchain_type].hip_libraries
        )
    else:
        fail("Cannot link shared objects with this toolchain.")

    return depset(direct)
