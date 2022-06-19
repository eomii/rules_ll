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
    return "bazel-out/{cpu}-{mode}/bin/{llvm_project_workspace}".format(
        cpu = ctx.var["TARGET_CPU"],
        mode = ctx.var["COMPILATION_MODE"],
        llvm_project_workspace = Label("@llvm-project").workspace_root,
    )

def _get_dirname(file):
    return file.dirname

def compile_object_args(ctx, in_file, out_file, cdf, headers, defines, includes, angled_includes):
    args = ctx.actions.args()

    args.add("-fcolor-diagnostics")

    # Visualization.
    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("-v")
        args.add("-glldb")

        if (
            "//ll:heterogeneous_toolchain_type" in ctx.toolchains and
            ctx.attr.heterogeneous_mode != "none"
        ):
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

    # Always generate position independent code.
    args.add("-fPIC")

    # Maybe enable heterogeneous compilation.
    if (
        "//ll:heterogeneous_toolchain_type" in ctx.toolchains and
        ctx.attr.heterogeneous_mode == "hip_nvidia"
    ):
        args.add("-xcuda")
        args.add(Label("@cuda_nvcc").workspace_root, format = "--cuda-path=%s")
        args.add_all(
            [
                Label("@cuda_cudart").workspace_root,
                Label("@cuda_nvprof").workspace_root,
                Label("@libcurand").workspace_root,
                Label("@hip").workspace_root,
                Label("@hipamd").workspace_root,
            ],
            format_each = "-I%s/include",
        )

    # Write compilation database.
    if "//ll:heterogeneous_toolchain_type" in ctx.toolchains and ctx.attr.heterogeneous_mode != "none":
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

    # Includes. This reflects the order in which clang will search for included
    # files.

    # 0. Search the directory of the including source file for quoted includes.

    # 1. Search directories specified via -iquote for quoted includes.
    args.add_all(includes, format_each = "-iquote%s", uniquify = True)

    # 2. Search directories specified via -I for quoted and angled includes.
    args.add_all(angled_includes, format_each = "-I%s", uniquify = True)

    # 3. Search directories specified via -isystem for quoted and angled
    #    includes.
    llvm_workspace_root = Label("@llvm-project").workspace_root
    libcxx_include_path = paths.join(llvm_workspace_root, "libcxx/include")
    args.add(clang_builtin_include_path, format = "-isystem%s")
    args.add(libcxx_include_path, format = "-isystem%s")
    libcxxabi_include_path = paths.join(llvm_workspace_root, "libcxxabi/include")
    args.add(libcxxabi_include_path, format = "-isystem%s")
    libunwind_include_path = paths.join(llvm_workspace_root, "libunwind/include")
    args.add(libunwind_include_path, format = "-isystem%s")

    # 4. Search directories specified via -idirafter for quoted and angled
    #    includes. Since most users will not need this flag, there is no
    #    attribute for it. Instead, it should be specified in the compile_flags
    #    attribute.

    # Defines.
    args.add_all(defines, format_each = "-D%s")

    # Additional compile flags.
    args.add_all(ctx.attr.compile_flags)

    # Input file.
    args.add(in_file)

    # Output file.
    args.add("-o", out_file)

    return [args]

def link_executable_args(ctx, in_files, out_file):
    args = ctx.actions.args()

    args.add("--color-diagnostics")

    # Visualization.
    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("--verbose")

    # Optimization.
    if ctx.var["COMPILATION_MODE"] != "dbg":
        args.add("--lto-O3")
        args.add("--strip-all")

    # Always create position independent executables.
    args.add("--pie")

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
        args.add("-lrt")
        args.add(Label("@cuda_cudart").workspace_root, format = "-L%s/lib")
        args.add("-lcudart_static")

    # Add local crt1.o, crti.o and crtn.o files.
    args.add_all(ctx.toolchains["//ll:toolchain_type"].local_crt)

    # Target-specific flags.
    args.add_all(ctx.attr.link_flags)

    # Add archives and objects.
    for file in in_files:
        if file.extension == "a" or file.extension == "o":
            args.add(file)

    args.add("-o", out_file)

    return [args]

def link_bitcode_library_args(ctx, in_files, out_file):
    args = ctx.actions.args()

    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("-v")

    args.add_all(ctx.attr.bitcode_link_flags)

    args.add_all(in_files)

    args.add("-o", out_file)

    return [args]

def link_shared_object_args(ctx, in_files, out_file):
    args = ctx.actions.args()

    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("--verbose")

    args.add("--shared")

    args.add_all(ctx.attr.shared_object_link_flags)

    args.add_all(in_files)

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
