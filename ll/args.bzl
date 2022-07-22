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

def llvm_bindir_path(ctx):
    return "{bindir}/{llvm_project_workspace}".format(
        bindir = ctx.var["BINDIR"],
        llvm_project_workspace = Label("@llvm-project").workspace_root,
    )

def llvm_gendir_path(ctx):
    return "{gendir}/{llvm_project_workspace}".format(
        gendir = ctx.var["GENDIR"],
        llvm_project_workspace = Label("@llvm-project").workspace_root,
    )

def _get_dirname(file):
    return file.dirname

def _construct_llvm_include_path(file):
    """Construct the paths to LLVM include directories.

    This function looks at a file, and strips everything after "llvm/include",
    so that the returned path is "<some_leading_path>/llvm/include". This lets
    us handle outputs in transitioned output directories.
    """
    filepath = file.path
    if filepath.find("/llvm/include/") != -1:
        first_segment = filepath.partition("/llvm/include/")[0]
        out = paths.join(first_segment, "llvm/include")
        return out

def _construct_clang_include_path(file):
    """Construct the paths to LLVM include directories.

    This function looks at a file, and strips everything after "clang/include",
    so that the returned path is "<some_leading_path>/clang/include". This lets
    us handle outputs in transitioned output directories.
    """
    filepath = file.path
    if filepath.find("/clang/include/") != -1:
        first_segment = filepath.partition("/clang/include/")[0]
        out = paths.join(first_segment, "clang/include")
        return out

def compile_object_args(
        ctx,
        in_file,
        out_file,
        cdf,
        headers,
        defines,
        includes,
        angled_includes):
    args = ctx.actions.args()

    args.add("-fcolor-diagnostics")

    # Visualization.
    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("-v")
        args.add("-fdebug-default-version=5")
        args.add("-fdebug-compilation-dir=.")
        args.add("-Xarch_host", "-glldb")

        if ctx.attr.compilation_mode in [
            "cuda_nvidia",
            "hip_nvidia",
        ]:
            args.add_all(["-Xarch_device", "-gdwarf-2"])
            args.add("--cuda-noopt-device-debug")

    # Sanitizers.
    has_sanitizers = (ctx.attr.sanitize != [])

    if "address" in ctx.attr.sanitize and "leak" in ctx.attr.sanitize:
        fail("AddressSanitizer and LeakSanitizer are mutually exclusive.")

    if has_sanitizers:
        args.add("-fno-omit-frame-pointer")
        args.add_all(["-Xarch_host", "-glldb"])
        args.add_all(["-Xarch_host", "-gdwarf-5"])

        if ctx.attr.compilation_mode in [
            "cuda_nvidia",
            "hip_nvidia",
        ]:
            args.add_all(["-Xarch_device", "-gdwarf-2"])
            args.add("--cuda-noopt-device-debug")

    if "address" in ctx.attr.sanitize:
        args.add("-fsanitize=address")
        args.add_all(["-mllvm", "-asan-force-dynamic-shadow=1"])

    if "memory" in ctx.attr.sanitize:
        args.add("-fsanitize=memory")

    if "leak" in ctx.attr.sanitize:
        args.add("-fsanitize=leak")

    if "thread" in ctx.attr.sanitize:
        args.add("-fsanitize=thread")

    if "undefined_behavior" in ctx.attr.sanitize:
        args.add("-fsanitize=undefined")

    # Optimization.
    if ctx.attr.compilation_mode in [
        "cuda_nvidia",
        "hip_nvidia",
    ] and ctx.var["COMPILATION_MODE"] != "dbg":
        args.add_all(["-Xarch_device", "-O3"])

    if ctx.var["COMPILATION_MODE"] == "opt":
        args.add("-O3")

        # Long double with 80 bits breaks LTO.
        if ctx.attr.compilation_mode == "none":
            args.add("-mlong-double-128")

        args.add("-flto=thin")

    # Only compile.
    args.add("-c")

    # Always generate position independent code.
    args.add("-fPIC")

    # Maybe enable heterogeneous compilation.
    if ctx.attr.compilation_mode in [
        "cuda_nvidia",
        "hip_nvidia",
    ]:
        args.add("-xcuda")
        args.add(
            Label("@cuda_nvcc").workspace_root,
            format = "--cuda-path=%s",
        )
        args.add_all(
            [
                Label("@cuda_cudart").workspace_root,
                Label("@cuda_nvprof").workspace_root,
                Label("@libcurand").workspace_root,
            ],
            format_each = "-I%s/include",
        )
    if ctx.attr.compilation_mode == "hip_nvidia":
        args.add_all(
            [
                Label("@hip").workspace_root,
                Label("@hipamd").workspace_root,
            ],
            format_each = "-I%s/include",
        )
    if ctx.attr.compilation_mode == "sycl_cpu":
        args.add(
            Label("@hipsycl//hipsycl_headers").workspace_root,
            format = "-I%s/include",
        )

        args.add("-fopenmp")
        args.add("-D_ENABLE_EXTENDED_ALIGNED_STORAGE")
        args.add("-D__HIPSYCL_ENABLE_OMPHOST_TARGET__")
        args.add(
            ctx.toolchains["//ll:toolchain_type"].hipsycl_plugin,
            format = "-fplugin=%s",
        )

        # TODO: We need this to get rid of hipSYCLs boost dependencies.
        # args.add(
        #     ctx.toolchains["//ll:toolchain_type"].hipsycl_plugin,
        #     format="-fpass-plugin=%s",
        # )
        args.add("-D__HIPSYCL_USE_ACCELERATED_CPU__")

    # Write compilation database.
    args.add("-Xarch_host")
    args.add(cdf, format = "-MJ%s")

    # Environment encapsulation.
    # args.add("-nostdinc")
    args.add("-nostdlib++")
    args.add("-nostdinc++")
    args.add("-nostdlib")
    args.add("--gcc-toolchain=NONE")

    clang_builtin_include_path = paths.join(
        llvm_bindir_path(ctx),
        "clang/staging",
    )

    args.add(clang_builtin_include_path, format = "-resource-dir=%s")

    # Internal Clang and LLVM header include paths. These are used by compilers
    # and compiler Plugins.
    if ctx.attr.llvm_project_deps != []:
        llvm_project_deps = depset(transitive = [
            data[OutputGroupInfo].compilation_prerequisites_INTERNAL_
            for data in ctx.attr.llvm_project_deps
        ])
        args.add_all(
            llvm_project_deps,
            map_each = _construct_llvm_include_path,
            format_each = "-idirafter%s",
            uniquify = True,
            omit_if_empty = True,
        )
        args.add_all(
            llvm_project_deps,
            map_each = _construct_clang_include_path,
            format_each = "-idirafter%s",
            uniquify = True,
            omit_if_empty = True,
        )

    # Includes. This reflects the order in which clang will search for included
    # files.

    # 0. Search the directory of the including source file for quoted includes.

    # 1. Search directories specified via -iquote for quoted includes.
    args.add_all(includes, format_each = "-iquote%s", uniquify = True)

    # 2. Search directories specified via -I for quoted and angled includes.
    args.add_all(angled_includes, format_each = "-I%s", uniquify = True)

    # 3. Search directories specified via -isystem for quoted and angled
    #    includes.
    args.add(
        paths.join(llvm_bindir_path(ctx), "libcxx/include"),
        format = "-isystem%s",
    )
    args.add(
        paths.join(llvm_bindir_path(ctx), "libcxxabi/include"),
        format = "-isystem%s",
    )
    args.add(
        paths.join(llvm_bindir_path(ctx), "libunwind/include"),
        format = "-isystem%s",
    )

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

def link_executable_args(ctx, in_files, out_file, mode):
    args = ctx.actions.args()

    args.add("--color-diagnostics")

    # Visualization.
    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("--verbose")

    # Sanitizers.
    has_sanitizers = (ctx.attr.sanitize != [])
    if has_sanitizers:
        args.add("--eh-frame-hdr")
        args.add("--whole-archive")

    if "address" in ctx.attr.sanitize and "leak" in ctx.attr.sanitize:
        fail("AddressSanitizer and LeakSanitizer are mutually exclusive.")

    if "address" in ctx.attr.sanitize:
        args.add_all(ctx.toolchains["//ll:toolchain_type"].address_sanitizer)

    if "leak" in ctx.attr.sanitize:
        args.add_all(ctx.toolchains["//ll:toolchain_type"].leak_sanitizer)

    if "memory" in ctx.attr.sanitize:
        args.add_all(ctx.toolchains["//ll:toolchain_type"].memory_sanitizer)

    if "thread" in ctx.attr.sanitize:
        args.add_all(ctx.toolchains["//ll:toolchain_type"].thread_sanitizer)

    if "undefined_behavior" in ctx.attr.sanitize:
        args.add_all(
            ctx.toolchains["//ll:toolchain_type"].undefined_behavior_sanitizer,
        )

    if has_sanitizers:
        args.add("--no-whole-archive")

    # Add dynamic linker.
    args.add("-dynamic-linker=/lib64/ld-linux-x86-64.so.2")

    # Optimization.
    if ctx.var["COMPILATION_MODE"] != "dbg":
        args.add("--lto-O3")

        if not has_sanitizers and ctx.var["COMPILATION_MODE"] == "opt":
            args.add("--strip-all")

    if mode == "executable":
        # Always create position independent executables.
        args.add("--pie")
    elif mode == "shared_object":
        args.add("--shared")
    else:
        fail("Invalid linking mode.")

    # Encapsulation.
    args.add("--nostdlib")

    # Additional system libraries.
    args.add("-L/usr/lib64")
    args.add("-lm")  # Math.
    args.add("-ldl")  # Dynamic linking.
    args.add("-lpthread")  # Thread support.
    args.add("-lc")  # Glibc.

    if ctx.attr.compilation_mode in [
        "cuda_nvidia",
        "hip_nvidia",
    ]:
        args.add("-lrt")
        args.add(Label("@cuda_cudart").workspace_root, format = "-L%s/lib")
        args.add("-lcudadevrt")
        args.add("-lcudart_static")

    if ctx.attr.compilation_mode == "sycl_cpu":
        args.add("-lomp")
        args.add(ctx.toolchains["//ll:toolchain_type"].hipsycl_runtime)

    # Target-specific flags.
    if mode == "executable":
        args.add_all(ctx.attr.link_flags)
    elif mode == "shared_object":
        args.add_all(ctx.attr.shared_object_link_flags)
    else:
        fail("Invalid linking mode")

    # Add archives and objects.
    link_files = [
        file
        for file in in_files.to_list()
        if file.extension in ["a", "o"]
    ]
    if mode == "executable":
        args.add_all(link_files)
    elif mode == "shared_object":
        reduced_link_files = [
            file
            for file in link_files
            if file not in ctx.toolchains["//ll:toolchain_type"].local_crt
        ]
        args.add_all(reduced_link_files)

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
