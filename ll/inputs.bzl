"""# `//ll:inputs.bzl`

Action inputs.
"""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

COMPILABLE_EXTENSIONS = [
    "ll",
    "c",
    "cl",
    "cpp",
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

    llvm_project_deps = [
        data[OutputGroupInfo].compilation_prerequisites_INTERNAL_
        for data in ctx.attr.llvm_project_deps
    ]

    interfaces = depset([file for file, _ in interfaces.to_list()])
    local_interfaces = [file for file, _ in local_interfaces]

    if config == "bootstrap":
        return depset(
            [in_file] +
            local_interfaces +
            ctx.files.srcs +
            ctx.files.data +
            ctx.toolchains[toolchain_type].builtin_includes,
            transitive = [
                headers,
                interfaces,
            ],
        )
    elif config == "cpp":
        return depset(
            [in_file] +
            local_interfaces +
            ctx.files.srcs +
            ctx.files.data +
            ctx.toolchains[toolchain_type].cpp_stdhdrs +
            ctx.toolchains[toolchain_type].cpp_abihdrs +
            ctx.toolchains[toolchain_type].compiler_runtime +
            ctx.toolchains[toolchain_type].builtin_includes,
            transitive = [
                headers,
                interfaces,
            ] + llvm_project_deps,
        )
    elif config == "cuda_nvidia":
        return depset(
            [in_file] +
            local_interfaces +
            ctx.files.srcs +
            ctx.files.data +
            ctx.toolchains[toolchain_type].cpp_stdhdrs +
            ctx.toolchains[toolchain_type].cpp_abihdrs +
            ctx.toolchains[toolchain_type].cuda_toolkit +
            ctx.toolchains[toolchain_type].builtin_includes,
            transitive = [
                headers,
                interfaces,
            ] + llvm_project_deps,
        )
    elif config == "hip_nvidia":
        return depset(
            [in_file] +
            local_interfaces +
            ctx.files.srcs +
            ctx.files.data +
            ctx.toolchains[toolchain_type].cpp_stdhdrs +
            ctx.toolchains[toolchain_type].cpp_abihdrs +
            ctx.toolchains[toolchain_type].cuda_toolkit +
            ctx.toolchains[toolchain_type].hip_libraries +
            ctx.toolchains[toolchain_type].builtin_includes,
            transitive = [
                headers,
                interfaces,
            ] + llvm_project_deps,
        )
    elif config == "sycl_cpu":
        return depset(
            [in_file] +
            local_interfaces +
            ctx.files.srcs +
            ctx.files.data +
            ctx.toolchains[toolchain_type].cpp_stdhdrs +
            ctx.toolchains[toolchain_type].cpp_abihdrs +
            ctx.toolchains[toolchain_type].builtin_includes +
            ctx.toolchains[toolchain_type].hipsycl_hdrs,
            transitive = [
                headers,
                interfaces,
            ] + llvm_project_deps,
        )
    else:
        fail("Cannot compile with this toolchain.")

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

    if config == "bootstrap":
        fail("Cannot link with bootstrap toolchain.")

    elif config == "cpp":
        return depset(
            in_files +
            ctx.files.deps +
            ctx.files.libraries +
            ctx.files.data +
            ctx.files.llvm_project_deps +
            ctx.toolchains[toolchain_type].cpp_stdlib +
            ctx.toolchains[toolchain_type].unwind_library +
            ctx.toolchains[toolchain_type].cpp_abilib +
            ctx.toolchains[toolchain_type].compiler_runtime,
        )
    elif config == "cuda_nvidia":
        return depset(
            in_files +
            ctx.files.deps +
            ctx.files.libraries +
            ctx.files.data +
            ctx.files.llvm_project_deps +
            ctx.toolchains[toolchain_type].cuda_toolkit +
            ctx.toolchains[toolchain_type].cpp_stdlib +
            ctx.toolchains[toolchain_type].unwind_library +
            ctx.toolchains[toolchain_type].cpp_abilib +
            ctx.toolchains[toolchain_type].compiler_runtime,
        )
    elif config == "hip_nvidia":
        return depset(
            in_files +
            ctx.files.deps +
            ctx.files.libraries +
            ctx.files.data +
            ctx.files.llvm_project_deps +
            ctx.toolchains[toolchain_type].cuda_toolkit +
            ctx.toolchains[toolchain_type].hip_libraries +
            ctx.toolchains[toolchain_type].cpp_stdlib +
            ctx.toolchains[toolchain_type].cpp_abilib +
            ctx.toolchains[toolchain_type].unwind_library +
            ctx.toolchains[toolchain_type].compiler_runtime,
        )
    elif config == "sycl_cpu":
        return depset(
            in_files +
            ctx.files.deps +
            ctx.files.libraries +
            ctx.files.data +
            ctx.files.llvm_project_deps +
            ctx.toolchains[toolchain_type].cpp_stdlib +
            ctx.toolchains[toolchain_type].unwind_library +
            ctx.toolchains[toolchain_type].cpp_abilib +
            ctx.toolchains[toolchain_type].compiler_runtime +
            [ctx.toolchains[toolchain_type].hipsycl_runtime],
        )
    else:
        fail("Cannot link with this toolchain.")

def link_bitcode_library_inputs(ctx, in_files):
    if "//ll:toolchain_type" in ctx.toolchains:
        return depset(in_files + ctx.files.deps + ctx.files.bitcode_libraries)
    else:
        fail("Can only link bitcode when using \"//ll:toolchain_type\".")

def link_shared_object_inputs(ctx, in_files, toolchain_type):
    config = ctx.attr.toolchain_configuration[BuildSettingInfo].value

    if config == "bootstrap":
        return depset(
            ctx.files.deps +
            ctx.files.data +
            ctx.files.llvm_project_deps,
        )

    elif config == "cpp":
        return depset(
            in_files +
            ctx.files.deps +
            ctx.files.data +
            ctx.files.llvm_project_deps +
            ctx.toolchains[toolchain_type].cpp_stdlib +
            ctx.toolchains[toolchain_type].cpp_abilib +
            ctx.toolchains[toolchain_type].unwind_library +
            ctx.toolchains[toolchain_type].compiler_runtime,
        )
    elif config == "cuda_nvidia":
        return depset(
            in_files +
            ctx.files.deps +
            ctx.files.data +
            ctx.files.llvm_project_deps +
            ctx.toolchains[toolchain_type].cpp_stdlib +
            ctx.toolchains[toolchain_type].cpp_abilib +
            ctx.toolchains[toolchain_type].unwind_library +
            ctx.toolchains[toolchain_type].compiler_runtime +
            ctx.toolchains[toolchain_type].cuda_toolkit,
        )
    elif config == "hip_nvidia":
        return depset(
            in_files +
            ctx.files.deps +
            ctx.files.data +
            ctx.files.llvm_project_deps +
            ctx.toolchains[toolchain_type].cpp_stdlib +
            ctx.toolchains[toolchain_type].cpp_abilib +
            ctx.toolchains[toolchain_type].unwind_library +
            ctx.toolchains[toolchain_type].compiler_runtime +
            ctx.toolchains[toolchain_type].cuda_toolkit +
            ctx.toolchains[toolchain_type].hip_libraries,
        )
    else:
        fail("Cannot link shared objects with this toolchain.")
