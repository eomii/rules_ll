"""# `//ll:toolchain.bzl`

Implements `ll_toolchain` and the internally used `ll_bootstrap_toolchain`.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//ll:providers.bzl", "LlInfo")
load(
    "//ll:attributes.bzl",
    "LL_BOOTSTRAP_TOOLCHAIN_ATTRS",
    "LL_HETEROGENEOUS_TOOLCHAIN_ATTRS",
    "LL_TOOLCHAIN_ATTRS",
)

def _ll_bootstrap_toolchain_impl(ctx):
    lld_alias = ctx.actions.declare_file("ld.lld")
    ctx.actions.symlink(
        output = lld_alias,
        target_file = ctx.executable.linker,
        target_path = None,
        is_executable = True,
    )

    return [
        platform_common.ToolchainInfo(
            c_driver = ctx.executable.c_driver,
            cpp_driver = ctx.executable.cpp_driver,
            archiver = ctx.executable.archiver,
            linker = lld_alias,
            builtin_includes = ctx.files.builtin_includes,
        ),
    ]

ll_bootstrap_toolchain = rule(
    implementation = _ll_bootstrap_toolchain_impl,
    executable = False,
    attrs = LL_BOOTSTRAP_TOOLCHAIN_ATTRS,
)

def _ll_toolchain_impl(ctx):
    lld_alias = ctx.actions.declare_file("ld.lld")
    ctx.actions.symlink(
        output = lld_alias,
        target_file = ctx.executable.linker,
        target_path = None,
        is_executable = True,
    )

    return [
        platform_common.ToolchainInfo(
            c_driver = ctx.executable.c_driver,
            cpp_driver = ctx.executable.cpp_driver,
            archiver = ctx.executable.archiver,
            bitcode_linker = ctx.executable.bitcode_linker,
            linker = lld_alias,
            linker_executable = ctx.executable.linker,
            builtin_includes = ctx.files.builtin_includes,
            cpp_stdlib = ctx.attr.cpp_stdlib,
            cpp_stdhdrs = ctx.attr.cpp_stdhdrs,
            cpp_abi = ctx.attr.cpp_abi,
            compiler_runtime = ctx.attr.compiler_runtime,
            unwind_library = ctx.attr.unwind_library,
            local_crt = ctx.files.local_crt,
            clang_tidy = ctx.executable.clang_tidy,
            clang_tidy_runner = ctx.executable.clang_tidy_runner,
            symbolizer = ctx.executable.symbolizer,
        ),
    ]

ll_toolchain = rule(
    implementation = _ll_toolchain_impl,
    executable = False,
    attrs = LL_TOOLCHAIN_ATTRS,
)

def _ll_heterogeneous_toolchain_impl(ctx):
    lld_alias = ctx.actions.declare_file("ld.lld")
    ctx.actions.symlink(
        output = lld_alias,
        target_file = ctx.executable.linker,
        target_path = None,
        is_executable = True,
    )

    return [
        platform_common.ToolchainInfo(
            c_driver = ctx.executable.c_driver,
            cpp_driver = ctx.executable.cpp_driver,
            archiver = ctx.executable.archiver,
            bitcode_linker = ctx.executable.bitcode_linker,
            linker = lld_alias,
            linker_executable = ctx.executable.linker,
            offload_bundler = ctx.executable.offload_bundler,
            builtin_includes = ctx.files.builtin_includes,
            cpp_stdlib = ctx.attr.cpp_stdlib,
            cpp_stdhdrs = ctx.attr.cpp_stdhdrs,
            cpp_abi = ctx.attr.cpp_abi,
            compiler_runtime = ctx.attr.compiler_runtime,
            unwind_library = ctx.attr.unwind_library,
            local_crt = ctx.files.local_crt,
            clang_tidy = ctx.executable.clang_tidy,
            clang_tidy_runner = ctx.executable.clang_tidy_runner,
            symbolizer = ctx.executable.symbolizer,
            machine_code_tool = ctx.executable.machine_code_tool,
            cuda_toolkit = ctx.files.cuda_toolkit,
            hip_libraries = ctx.files.hip_libraries,
        ),
    ]

ll_heterogeneous_toolchain = rule(
    implementation = _ll_heterogeneous_toolchain_impl,
    executable = False,
    attrs = LL_HETEROGENEOUS_TOOLCHAIN_ATTRS,
)
