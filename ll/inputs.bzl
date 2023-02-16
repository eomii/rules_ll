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
        interfaces):
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value
    toolchain = ctx.toolchains["//ll:toolchain_type"]

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
        direct += (
            toolchain.omp_header
        )
    elif config == "cuda_nvptx":
        direct += (
            toolchain.cuda_toolkit
        )
    elif config == "hip_nvptx":
        direct += (
            toolchain.cuda_toolkit +
            toolchain.hip_libraries
        )
    elif config == "sycl_cpu":
        direct += toolchain.hipsycl_hdrs
    elif config == "sycl_cuda":
        direct += (
            toolchain.cuda_toolkit +
            toolchain.hipsycl_hdrs
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

def link_executable_inputs(ctx, in_files):
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
        direct += (
            toolchain.libomp
        )
    elif config == "cuda_nvptx":
        direct += (
            toolchain.cuda_toolkit +
            [toolchain.cuda_libdir] +
            [toolchain.cuda_bindir] +
            [toolchain.cuda_nvvm]
        )

    elif config == "hip_nvptx":
        direct += (
            toolchain.cuda_toolkit +
            [toolchain.cuda_libdir] +
            [toolchain.cuda_bindir] +
            [toolchain.cuda_nvvm] +
            toolchain.hip_libraries
        )
    elif config == "sycl_cpu":
        direct += [
            toolchain.hipsycl_runtime,
            toolchain.hipsycl_omp_backend,
        ]
    elif config == "sycl_cuda":
        direct += (
            toolchain.cuda_toolkit +
            [
                toolchain.cuda_bindir,
                toolchain.cuda_libdir,
                toolchain.cuda_nvvm,
                toolchain.hipsycl_runtime,
                # toolchain.hipsycl_omp_backend,
                # toolchain.hipsycl_cuda_backend,
            ]
        )
    else:
        fail("Cannot link with this toolchain.")

    return depset(direct)

def link_bitcode_library_inputs(ctx, in_files):
    return depset(in_files + ctx.files.deps + ctx.files.bitcode_libraries)

def link_shared_object_inputs(ctx, in_files):
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
        direct += (
            toolchain.cuda_toolkit +
            [toolchain.cuda_libdir] +
            [toolchain.cuda_nvvm]
        )

    elif config == "hip_nvptx":
        direct += (
            toolchain.cuda_toolkit +
            [toolchain.cuda_libdir] +
            [toolchain.cuda_nvvm] +
            toolchain.hip_libraries
        )
    else:
        fail("Cannot link shared objects with this toolchain.")

    return depset(direct)
