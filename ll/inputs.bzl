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

def compile_object_inputs(ctx, headers):
    if "//ll:toolchain_type" in ctx.toolchains:
        third_party_deps = depset()
        if ctx.attr.heterogeneous_mode in ["hip_nvidia", "hip_amd"]:
            third_party_deps = depset(
                ctx.toolchains["//ll:toolchain_type"].hip_libraries,
                transitive = [third_party_deps],
            )
        if ctx.attr.heterogeneous_mode in ["hip_nvidia"]:
            third_party_deps = depset(
                ctx.toolchains["//ll:toolchain_type"].cuda_toolkit,
                transitive = [third_party_deps],
            )

        return depset(
            ctx.files.srcs +
            ctx.files.data +
            ctx.toolchains["//ll:toolchain_type"].builtin_includes,
            transitive = [
                headers,
                ctx.toolchains["//ll:toolchain_type"].cpp_stdhdrs.files,
                ctx.toolchains["//ll:toolchain_type"].cpp_abi[LlInfo].transitive_headers,
                third_party_deps,
            ],
        )
    elif "//ll:bootstrap_toolchain_type" in ctx.toolchains:
        return depset(
            ctx.files.srcs +
            ctx.files.data +
            ctx.toolchains["//ll:bootstrap_toolchain_type"].builtin_includes,
            transitive = [headers],
        )
    else:
        fail("Unregognized toolchain type. rules_ll supports " +
             "//ll:toolchain_type and //ll:bootstrap_toolchain_type.")

def create_archive_library_inputs(ctx, in_files):
    return depset(in_files + ctx.files.deps)

def link_executable_inputs(ctx, in_files):
    if "//ll:toolchain_type" in ctx.toolchains:
        third_party_deps = depset()
        if ctx.attr.heterogeneous_mode in ["hip_nvidia", "hip_amd"]:
            third_party_deps = depset(
                ctx.toolchains["//ll:toolchain_type"].hip_libraries,
                transitive = [third_party_deps],
            )
        if ctx.attr.heterogeneous_mode in ["hip_nvidia"]:
            third_party_deps = depset(
                ctx.toolchains["//ll:toolchain_type"].cuda_toolkit,
                transitive = [third_party_deps],
            )

        return depset(
            in_files +
            ctx.files.deps +
            ctx.files.libraries +
            ctx.files.data +
            ctx.toolchains["//ll:toolchain_type"].local_crt,
            transitive = [
                ctx.toolchains["//ll:toolchain_type"].cpp_stdlib.files,
                ctx.toolchains["//ll:toolchain_type"].unwind_library.files,
                ctx.toolchains["//ll:toolchain_type"].cpp_abi.files,
                ctx.toolchains["//ll:toolchain_type"].compiler_runtime.files,
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
