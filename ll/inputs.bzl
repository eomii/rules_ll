"""# `//ll:inputs.bzl`

Action inputs.
"""

load("//ll:providers.bzl", "LlInfo")

def compilable_sources(ctx):
    compilable_extensions = ["ll", "c", "cl", "cpp", "S", "cc"]
    return [
        src
        for src in ctx.files.srcs
        if src.extension in compilable_extensions
    ]

def compile_object_inputs(ctx, headers, toolchain_type):
    if toolchain_type == "//ll:toolchain_type":
        return depset(
            ctx.files.srcs +
            ctx.files.data +
            ctx.toolchains[toolchain_type].builtin_includes,
            transitive = [
                headers,
                ctx.toolchains[toolchain_type].cpp_stdhdrs.files,
                ctx.toolchains[toolchain_type].cpp_abi[LlInfo].transitive_hdrs,
            ],
        )
    elif toolchain_type == "//ll:heterogeneous_toolchain_type":
        heterogeneous_deps = depset()
        if ctx.attr.heterogeneous_mode in ["hip_nvidia", "hip_amd"]:
            heterogeneous_deps = depset(
                ctx.toolchains[toolchain_type].hip_libraries,
                transitive = [heterogeneous_deps],
            )
        if ctx.attr.heterogeneous_mode in ["hip_nvidia"]:
            heterogeneous_deps = depset(
                ctx.toolchains[toolchain_type].cuda_toolkit,
                transitive = [heterogeneous_deps],
            )
        return depset(
            ctx.files.srcs +
            ctx.files.data +
            ctx.toolchains[toolchain_type].builtin_includes,
            transitive = [
                headers,
                ctx.toolchains[toolchain_type].cpp_stdhdrs.files,
                ctx.toolchains[toolchain_type].cpp_abi[LlInfo].transitive_hdrs,
                heterogeneous_deps,
            ],
        )
    elif toolchain_type == "//ll:bootstrap_toolchain_type":
        return depset(
            ctx.files.srcs +
            ctx.files.data +
            ctx.toolchains[toolchain_type].builtin_includes,
            transitive = [headers],
        )
    else:
        fail("Unregognized toolchain type. rules_ll supports " +
             "//ll:toolchain_type and //ll:bootstrap_toolchain_type.")

def create_archive_library_inputs(ctx, in_files):
    return depset(in_files + ctx.files.deps)

def link_executable_inputs(ctx, in_files, toolchain_type):
    if toolchain_type == "//ll:toolchain_type":
        return depset(
            in_files +
            ctx.files.deps +
            ctx.files.libraries +
            ctx.files.data +
            ctx.toolchains[toolchain_type].local_crt,
            transitive = [
                ctx.toolchains[toolchain_type].cpp_stdlib.files,
                ctx.toolchains[toolchain_type].unwind_library.files,
                ctx.toolchains[toolchain_type].cpp_abi.files,
                ctx.toolchains[toolchain_type].compiler_runtime.files,
            ],
        )
    elif toolchain_type == "//ll:heterogeneous_toolchain_type":
        heterogeneous_deps = depset()
        if ctx.attr.heterogeneous_mode in ["hip_nvidia", "hip_amd"]:
            heterogeneous_deps = depset(
                ctx.toolchains[toolchain_type].hip_libraries,
                transitive = [heterogeneous_deps],
            )
        if ctx.attr.heterogeneous_mode in ["hip_nvidia"]:
            heterogeneous_deps = depset(
                ctx.toolchains[toolchain_type].cuda_toolkit,
                transitive = [heterogeneous_deps],
            )
        return depset(
            in_files +
            ctx.files.deps +
            ctx.files.libraries +
            ctx.files.data +
            ctx.toolchains[toolchain_type].local_crt,
            transitive = [
                ctx.toolchains[toolchain_type].cpp_stdlib.files,
                ctx.toolchains[toolchain_type].unwind_library.files,
                ctx.toolchains[toolchain_type].cpp_abi.files,
                ctx.toolchains[toolchain_type].compiler_runtime.files,
                heterogeneous_deps,
            ],
        )

    if toolchain_type in ["//ll:toolchain_type", "//ll:heterogeneous_toolchain_type"]:
        if ctx.attr.heterogeneous_mode in ["hip_nvidia", "hip_amd"]:
            third_party_deps = depset(
                ctx.toolchains[toolchain_type].hip_libraries,
                transitive = [third_party_deps],
            )
        if ctx.attr.heterogeneous_mode in ["hip_nvidia"]:
            third_party_deps = depset(
                ctx.toolchains[toolchain_type].cuda_toolkit,
                transitive = [third_party_deps],
            )
        return depset(
            in_files +
            ctx.files.deps +
            ctx.files.libraries +
            ctx.files.data +
            ctx.toolchains[toolchain_type].local_crt,
            transitive = [
                ctx.toolchains[toolchain_type].cpp_stdlib.files,
                ctx.toolchains[toolchain_type].unwind_library.files,
                ctx.toolchains[toolchain_type].cpp_abi.files,
                ctx.toolchains[toolchain_type].compiler_runtime.files,
                third_party_deps,
            ],
        )
    else:
        fail("Can only link when using \"//ll:toolchain_type\".")

def link_bitcode_library_inputs(ctx, in_files):
    if "//ll:toolchain_type" in ctx.toolchains:
        return depset(in_files + ctx.files.deps + ctx.files.bitcode_libraries)
    else:
        fail("Can only link bitcode when using \"//ll:toolchain_type\".")

def link_shared_object_inputs(ctx, in_files):
    if "//ll:toolchain_type" in ctx.toolchains:
        return depset(in_files + ctx.files.deps)
    else:
        fail("Can only link shared object when using \"//ll:toolchain_type\".")
