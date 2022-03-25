"""# `//ll:toolchain.bzl`

Implements `ll_toolchain` and the internally used `ll_bootstrap_toolchain`.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//ll:providers.bzl", "LlInfo")

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
    attrs = {
        "c_driver": attr.label(
            doc = "The C compiler driver.",
            executable = True,
            allow_single_file = True,
            cfg = "exec",
            default = "@llvm-project//clang:clang",
        ),
        "cpp_driver": attr.label(
            doc = "The C++ compiler driver.",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = "@llvm-project//clang:clang++",
        ),
        "archiver": attr.label(
            doc = "The archiver.",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = "@llvm-project//llvm:llvm-ar",
        ),
        "linker": attr.label(
            doc = "The linker.",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = "@llvm-project//lld:lld",
        ),
        "builtin_includes": attr.label(
            doc = "Builtin header files. Defaults to @llvm-project//clang:builtin_headers_gen",
            cfg = "target",
            default = "@llvm-project//clang:builtin_headers_gen",
        ),
    },
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
        ),
    ]

ll_toolchain = rule(
    implementation = _ll_toolchain_impl,
    executable = False,
    attrs = {
        "c_driver": attr.label(
            doc = "The C compiler driver.",
            executable = True,
            allow_single_file = True,
            cfg = "exec",
            default = "@llvm-project//clang:clang",
        ),
        "cpp_driver": attr.label(
            doc = "The C++ compiler driver.",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = "@llvm-project//clang:clang++",
        ),
        "archiver": attr.label(
            doc = "The archiver.",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = "@llvm-project//llvm:llvm-ar",
        ),
        "linker": attr.label(
            doc = "The linker.",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = "@llvm-project//lld:lld",
        ),
        "builtin_includes": attr.label_list(
            doc = "Builtin header files for the compiler.",
            cfg = "target",
            default = [
                "@llvm-project//clang:builtin_headers_gen",
            ],
        ),
        "bitcode_linker": attr.label(
            doc = """The linker for LLVM bitcode files. While `llvm-ar` is able
            to archive bitcode files into an archive, it cannot link them into
            a single bitcode file. We need `llvm-link` to do this.
            """,
            executable = True,
            cfg = "exec",
            default = "@llvm-project//llvm:llvm-link",
        ),
        "cpp_stdlib": attr.label(
            doc = "The C++ standard library archive.",
            cfg = "target",
            default = "@llvm-project//libcxx:libll_cxx",
            providers = [LlInfo],
        ),
        "cpp_stdhdrs": attr.label(
            doc = "The C++ standard library headers.",
            cfg = "target",
            default = "@llvm-project//libcxx:libcxx_headers",
            allow_files = True,
        ),
        "cpp_abi": attr.label(
            doc = "The C++ ABI library archive.",
            cfg = "target",
            default = "@llvm-project//libcxxabi:libll_cxxabi",
            providers = [LlInfo],
        ),
        "compiler_runtime": attr.label(
            doc = "The compiler runtime.",
            cfg = "target",
            default = "@llvm-project//compiler-rt:libll_compiler-rt",
            providers = [LlInfo],
        ),
        "unwind_library": attr.label(
            doc = "The unwinder library.",
            cfg = "target",
            default = "@llvm-project//libunwind:libll_unwind",
        ),
        "local_crt": attr.label(
            doc = "A filegroup containing the system's local crt1.o, crti.o and crtn.o files.",
            default = "@local_crt//:crt",
        ),
        "clang_tidy": attr.label(
            doc = "The clang-tidy executable.",
            cfg = "exec",
            default = "@llvm-project//clang-tools-extra/clang-tidy:clang-tidy",
            executable = True,
        ),
        "clang_tidy_runner": attr.label(
            doc = "The run-clang-tidy.py wrapper script for clang-tidy. Enables multithreading.",
            cfg = "exec",
            default = "@llvm-project//clang-tools-extra/clang-tidy:run-clang-tidy",
            executable = True,
        ),
        "offload_bundler": attr.label(
            doc = """Offload bundler used to bundle code objects for languages
            targeting multiple devices in a single source file, e.g. GPU code.
            """,
            cfg = "exec",
            default = "@llvm-project//clang:clang-offload-bundler",
            executable = True,
        ),
        "symbolizer": attr.label(
            doc = "The llvm-symbolizer.",
            cfg = "exec",
            default = "@llvm-project//llvm:llvm-symbolizer",
            executable = True,
        ),
        "machine_code_tool": attr.label(
            doc = "The llvm-mc tool. Used for separarable compilation (CUDA/HIP).",
            cfg = "exec",
            default = "@llvm-project//llvm:llvm-mc",
            executable = True,
        ),
    },
)
