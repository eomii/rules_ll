"""# `//ll:args.bzl`

Convenience function for setting compile arguments.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")

def llvm_target_directory_path(ctx):
    """Returns the path to the `llvm-project` build output directory.

    The path looks like `bazel-out/{cpu}-{mode}/bin/external/llvm-project`.

    Args:
        ctx: The rule context.

    Returns:
        A string.
    """
    return "bazel-out/{cpu}-{mode}/bin/external/llvm-project".format(
        cpu = ctx.var["TARGET_CPU"],
        mode = ctx.var["COMPILATION_MODE"],
    )

def _get_dirname(file):
    return file.dirname

def compile_object_args(ctx, in_file, out_file, cdf, headers, defines, includes):
    args = ctx.actions.args()

    args.add("-fcolor-diagnostics")

    # Visualization.
    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("-v")
        args.add("-glldb")
        if ctx.attr.heterogeneous_mode != "none":
            args.add("--cuda-noopt-device-debug")

    # Optimization.
    if ctx.var["COMPILATION_MODE"] == "opt":
        args.add("-O3")

        # Long double with 80 bits breaks LTO.
        if ctx.attr.heterogeneous_mode == "none":
            args.add("-mlong-double-128")
        args.add("-flto=thin")

    # Only compile.
    args.add("-c")

    # Maybe enable heterogeneous compilation.
    if ctx.attr.heterogeneous_mode == "hip_nvidia":
        args.add("-xcuda")
        args.add("--cuda-path=/usr/local/cuda")

    # Write compilation database.
    if ctx.attr.heterogeneous_mode != "none":
        args.add("-Xarch_host")
        args.add(cdf, format = "-MJ%s")
    else:
        args.add(cdf, format = "-MJ%s")

    # Environment encapsulation.
    # args.add("-nostdinc")
    args.add("-nostdlib++")
    args.add("-nostdinc++")
    args.add("-nostdlib")
    args.add("--gcc-toolchain=NONE")

    clang_builtin_include_path = paths.join(
        llvm_target_directory_path(ctx),
        "clang/staging",
    )
    args.add(clang_builtin_include_path, format = "-resource-dir=%s")

    # Ensure that #include_next works properly in cuda_wrappers/algorithm.
    args.add(clang_builtin_include_path, format = "-isystem%s")

    libcxx_include_path = "external/llvm-project/libcxx/include"
    args.add(libcxx_include_path, format = "-isystem%s")

    # Target-specific flags.
    args.add_all(
        headers,
        format_each = "-I%s",
        map_each = _get_dirname,
        uniquify = True,
    )
    args.add_all(includes, format_each = "-I%s", uniquify = True)
    args.add_all(defines, format_each = "-D%s")

    args.add_all(ctx.attr.compile_flags)

    args.add(in_file)
    args.add("-o", out_file)

    return [args]

def link_executable_args(ctx, in_files, out_file):
    args = ctx.actions.args()

    args.add("--color-diagnostics")

    # Visualization.
    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("--verbose")

    # Optimization.
    if ctx.var["COMPILATION_MODE"] == "opt":
        args.add("--lto-O3")
        args.add("--strip-all")

    # Encapsulation.
    args.add("--nostdlib")

    # Add dynamic linker.
    args.add("-dynamic-linker=/lib64/ld-linux-x86-64.so.2")

    # Use compiler-rt as runtime.
    compiler_rt_path = paths.join(
        llvm_target_directory_path(ctx),
        "compiler-rt",
    )
    args.add(compiler_rt_path, format = "-L%s")
    args.add(compiler_rt_path, format = "--rpath=%s")
    args.add("-lll_compiler-rt")

    # Use libunwind as unwinder library.
    libunwind_path = paths.join(
        llvm_target_directory_path(ctx),
        "libunwind",
    )
    args.add(libunwind_path, format = "-L%s")
    args.add("-lll_unwind")

    # Use custom libc++.
    libcxx_path = paths.join(
        llvm_target_directory_path(ctx),
        "libcxx",
    )
    args.add(libcxx_path, format = "-L%s")
    args.add(libcxx_path, format = "--rpath=%s")
    args.add("-lll_cxx")

    # Use custom libc++abi.
    libcxxabi_path = paths.join(
        llvm_target_directory_path(ctx),
        "libcxxabi",
    )
    args.add(libcxxabi_path, format = "-L%s")
    args.add(libcxxabi_path, format = "--rpath=%s")
    args.add("-lll_cxxabi")

    # Additional system libraries.
    args.add("-L/usr/lib64")
    args.add("-lm")  # Required for math-related functions.
    args.add("-ldl")  # Required by libunwind.
    args.add("-lpthread")  # Required by libunwind.
    args.add("-lc")  # Required. This is glibc.

    if ctx.attr.heterogeneous_mode == "hip_nvidia":
        args.add("-L/usr/local/cuda/lib64")
        args.add("-lrt")
        args.add("-lcudart_static")

    # Add local crt1.o, crti.o and crtn.o files.
    args.add_all(ctx.toolchains["//ll:toolchain_type"].local_crt)

    # Target-specific flags.
    args.add_all(ctx.attr.link_flags)
    args.add_all(in_files)
    args.add("-o", out_file)

    return [args]

def link_bitcode_library_args(ctx, in_files, out_file):
    args = ctx.actions.args()

    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("-v")

    args.add_all(ctx.attr.bitcode_link_flags)

    args.add_all(in_files)

    out_file = ctx.actions.declare_file(ctx.label.name + ".bc")
    args.add("-o", out_file)

    return [args]

def create_archive_library_args(ctx, in_files, out_file):
    args = ctx.actions.args()

    # -v: Verbose.
    # -c: Do not warn when creating a new archive.
    # -q: Quick-append inputs.
    # -L: Quick append archive members instead of the archive itself if an
    #     archive is part of the inputs.
    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("-vqL")
    else:
        args.add("-cqL")

    args.add(out_file)
    args.add_all(in_files)

    return [args]

def expose_headers_args(ctx, in_file, out_file):
    args = ctx.actions.args()
    args.add(in_file)
    args.add(out_file.dirname)
    return [args]
