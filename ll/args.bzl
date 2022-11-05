"""# `//ll:args.bzl`

Convenience function for setting compile arguments.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//ll:llvm_project_deps.bzl", "LINUX_DEFINES")
load("//ll:os.bzl", "library_path")

def llvm_bindir_path(ctx):
    return "{bindir}/{llvm_project_workspace}".format(
        bindir = ctx.var["BINDIR"],
        llvm_project_workspace = Label("@llvm-project").workspace_root,
    )

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

def _create_module_import(interface):
    file, module_name = interface
    out = "{}={}".format(module_name, file.path)
    return out

def _create_local_module_import(interface):
    file, module_name = interface
    out = "{}".format(file.path)
    return out

def _get_dirname(file):
    """Returns file.dirname."""
    return file.dirname

def _get_basename(file):
    """Returns file.dirname."""
    return file.basename

def _get_owner_package(file):
    """Returns file.owner.workspace_root + file.owner.package."""
    return file.owner.workspace_root + file.owner.package

def compile_object_args(
        ctx,
        in_file,
        out_file,
        cdf,
        headers,
        defines,
        includes,
        angled_includes,
        bmis,
        internal_bmis):
    args = ctx.actions.args()

    args.add("-fcolor-diagnostics")

    # Reproducibility.
    args.add("-Wdate-time")
    args.add("-no-canonical-prefixes")
    args.add("-fdebug-compilation-dir=.")
    args.add("-fno-coverage-mapping")  # TODO: Enable with hermetic path.

    # Visualization.
    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("-v")
        args.add("-Xarch_host", "-glldb")

        if ctx.attr.compilation_mode in [
            "cuda_nvidia",
            "hip_nvidia",
            "sycl_cuda",
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
            "sycl_cuda",
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
        "sycl_cuda",
    ] and ctx.var["COMPILATION_MODE"] != "dbg":
        args.add_all(["-Xarch_device", "-O3"])

    if ctx.var["COMPILATION_MODE"] == "opt":
        args.add("-O3")

        # Long double with 80 bits breaks LTO.
        if ctx.attr.compilation_mode == "none":
            args.add("-mlong-double-128")

        args.add("-flto=thin")

    # When in_file has the extension .cppm, we precompile to a .pcm file. This
    # precompiled module is compiled to an object file with a .o extension in a
    # second step, where in_file has a .pcm extension. This way we can reduce
    # compile times by importing the precompiled module instead of recompiling
    # the module upon every import declaration.
    if in_file.extension == "cppm":
        args.add("--precompile")
    else:
        args.add("-c")

    # Always generate position independent code.
    args.add("-fPIC")

    # Maybe enable heterogeneous compilation.
    if ctx.attr.compilation_mode in [
        "cuda_nvidia",
        "hip_nvidia",
        "sycl_cuda",
    ]:
        args.add("-Wno-unknown-cuda-version")  # Will always be unknown.
        args.add("-xcuda")
        args.add(
            Label("@cuda_nvcc").workspace_root,
            format = "--cuda-path=%s",
        )
        args.add_all(
            [
                Label("@cuda_cudart").workspace_root,
                Label("@cuda_nvprof").workspace_root,
                Label("@cuda_profiler_api").workspace_root,
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
    if ctx.attr.compilation_mode in ["sycl_cpu", "sycl_cuda"]:
        args.add(
            Label("@hipsycl//hipsycl_headers").workspace_root,
            format = "-I%s/include",
        )
        args.add("-D__HIPSYCL__")
        args.add("-D__HIPSYCL_CLANG__")
        args.add("-D__HIPSYCL_ENABLE_OMPHOST_TARGET__")

        if ctx.attr.compilation_mode == "sycl_cuda":
            args.add("-D__HIPSYCL_ENABLE_CUDA_TARGET__")
            args.add("-U__FLOAT128__")
            args.add("-U__SIZEOF_FLOAT128__")

        args.add(
            ctx.toolchains["//ll:toolchain_type"].hipsycl_plugin,
            format = "-fplugin=%s",
        )

        args.add(
            ctx.toolchains["//ll:toolchain_type"].hipsycl_plugin,
            format = "-fpass-plugin=%s",
        )

        args.add("-D_ENABLE_EXTENDED_ALIGNED_STORAGE")

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

    # Includes. This reflects the order in which clang will search for included
    # files.

    # 0. Search the directory of the including source file for quoted includes.

    # 1. Search directories specified via -iquote for quoted includes.
    args.add_all(includes, format_each = "-iquote%s", uniquify = True)

    # 2. Search directories specified via -I for quoted and angled includes.
    args.add_all(angled_includes, format_each = "-I%s", uniquify = True)

    # 3. Search directories specified via -isystem for quoted and angled
    #    includes. This is not exposed via target attributes.
    if in_file.extension != "pcm":
        # Objects compiled from modules already contain these from the
        # precompilation step.
        llvm_workspace_root = Label("@llvm-project").workspace_root
        args.add_all(
            [
                clang_builtin_include_path,
                paths.join(llvm_workspace_root, "libcxx/include"),
                paths.join(llvm_workspace_root, "libcxxabi/include"),
                paths.join(llvm_workspace_root, "libunwind/include"),
            ],
            format_each = "-isystem%s",
        )

    # 4. Search directories specified via -idirafter for quoted and angled
    #    includes. Since most users will not need this flag, there is no
    #    attribute for it. For non-LLVM related include paths, users should
    #    specify these in the compile_flags attribute.
    if ctx.attr.depends_on_llvm:
        args.add_all(
            ctx.toolchains["//ll:toolchain_type"].llvm_project_sources,
            map_each = _construct_llvm_include_path,
            format_each = "-idirafter%s",
            uniquify = True,
            omit_if_empty = True,
        )
        args.add_all(
            ctx.toolchains["//ll:toolchain_type"].llvm_project_sources,
            map_each = _construct_clang_include_path,
            format_each = "-idirafter%s",
            uniquify = True,
            omit_if_empty = True,
        )

    # Defines.
    args.add_all(defines, format_each = "-D%s")
    if ctx.attr.depends_on_llvm:
        args.add_all(
            LINUX_DEFINES,
            format_each = "-D%s",
        )

    # Always use experimental libcxx features.
    args.add("-D_LIBCPP_ENABLE_EXPERIMENTAL")

    # TODO: Module precompilations embed absolute paths in precompiled binaries.
    # We use this workaround to prevent abi_tag attribute redeclaration errors
    # in libcxx/include/__bit_reference. We need to figure out how we can
    # re-enable abi-tagging.
    args.add("-D_LIBCPP_NO_ABI_TAG")

    # Additional compile flags.
    args.add_all(ctx.attr.compile_flags)

    # To keep precompilations sandboxed, embed used headers in the pcm.
    # TODO: This does not work yet. For some reason we are still required to
    #       disable sandboxing in precompilations.
    if out_file.extension == "pcm":
        args.add("-Xclang")
        args.add("-fmodules-embed-all-files")

    # Load local module interfaces unconditionally without declaring a module
    # name. When these are made available to downstream targets, they will be
    # treated as modules. This issue is caused by `module M;` not implicitly
    # declaring a dependency on `M` in the same way that `import M` would.
    # TODO: This is probably a bug in Clang. Discussion at
    #       https://github.com/llvm/llvm-project/issues/57293.
    args.add_all(
        internal_bmis,
        map_each = _create_local_module_import,
        format_each = "-fmodule-file=%s",
        uniquify = True,
        omit_if_empty = True,
    )

    # Load modules conditionally by declaring the module name.
    args.add_all(
        bmis,
        map_each = _create_module_import,
        format_each = "-fmodule-file=%s",
        uniquify = True,
        omit_if_empty = True,
    )

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

    # Startup files.
    if mode == "executable":
        args.add(
            ctx.toolchains["//ll:toolchain_type"].local_library_path.path,
            format = "%s/Scrt1.o",
        )
        args.add(
            ctx.toolchains["//ll:toolchain_type"].local_library_path.path,
            format = "%s/crti.o",
        )

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
    args.add(
        ctx.toolchains["//ll:toolchain_type"].local_library_path.path,
        format = "-L%s",
    )

    args.add("-lm")  # Math.
    args.add("-ldl")  # Dynamic linking.
    args.add("-lpthread")  # Thread support.
    args.add("-lc")  # Glibc.

    if ctx.attr.compilation_mode in [
        "cuda_nvidia",
        "hip_nvidia",
        "sycl_cuda",
    ]:
        args.add("-lrt")
        args.add(Label("@cuda_cudart").workspace_root, format = "-L%s/lib")
        args.add(Label("@cuda_nvcc").workspace_root, format = "-L%s/nvvm/lib64")
        args.add(
            ctx.toolchains["//ll:toolchain_type"].cuda_libdir.short_path[3:],
            format = "-rpath=$ORIGIN/../external/%s",
        )
        args.add(
            ctx.toolchains["//ll:toolchain_type"].cuda_nvvm.short_path[3:],
            format = "-rpath=$ORIGIN/../external/%s",
        )
        if ctx.label.name != "rt-backend-cuda":
            args.add("-lcudart")

    if ctx.attr.compilation_mode in ["sycl_cpu", "sycl_cuda"]:
        args.add("-lomp")
        sycl_shared_libraries = [
            ctx.toolchains["//ll:toolchain_type"].hipsycl_runtime,
            # ctx.toolchains["//ll:toolchain_type"].hipsycl_omp_backend,
        ]
        args.add_all(
            sycl_shared_libraries,
            map_each = _get_dirname,
            format_each = "-L%s",
            uniquify = True,
            omit_if_empty = True,
        )
        args.add_all(
            sycl_shared_libraries,
            map_each = _get_basename,
            format_each = "-l:%s",
            uniquify = True,
            omit_if_empty = True,
        )
        args.add_all(
            sycl_shared_libraries,
            map_each = _get_owner_package,
            format_each = "-rpath=$ORIGIN/../%s",
            uniquify = True,
            omit_if_empty = True,
        )
        if ctx.attr.compilation_mode in ["sycl_cpu", "sycl_cuda"]:
            args.add("--rpath=$ORIGIN/../external/@rules_ll.override/ll")
            args.add("--rpath=$ORIGIN/../external/@rules_ll.override/ll/hipSYCL")

    # Target-specific flags.
    if mode == "executable":
        args.add_all(ctx.attr.link_flags)
    elif mode == "shared_object":
        args.add_all(ctx.attr.shared_object_link_flags)
    else:
        fail("Invalid linking mode")

    # Add archives and objects.
    # if ctx.attr.depends_on_llvm:
    link_files = [
        file
        for file in in_files.to_list()
        if file.extension in ["a", "o"]
    ]
    # else:
    #     link_files = [
    #         file
    #         for file in in_files.to_list()
    #         if file.extension == "o"
    #     ] + [
    #         file
    #         for file in ctx.files.deps
    #         if file.extension == "a"
    #     ]
    # link_files = [
    #     file
    #     for file in in_files.to_list()
    #     if file.extension in ["a", "o"]
    # ]

    args.add_all(link_files)

    # Link shared libraries in a way that is accessible via `bazel run` and
    # via manual execution, as long as the relative paths to the shared
    # libraries remain the same.
    # TODO: Handle LLVM shared libraries.
    shared_link_files = [
        file
        for file in ctx.files.deps
        if file.extension == "so"
    ]
    args.add_all(
        shared_link_files,
        map_each = _get_dirname,
        format_each = "-L%s",
        uniquify = True,
        omit_if_empty = True,
    )
    args.add_all(
        shared_link_files,
        map_each = _get_basename,
        format_each = "-l:%s",
        uniquify = True,
        omit_if_empty = True,
    )
    args.add_all(
        shared_link_files,
        map_each = _get_owner_package,
        format_each = "-rpath=$ORIGIN/../%s",
        uniquify = True,
        omit_if_empty = True,
    )

    # End files.
    if mode == "executable":
        args.add(
            ctx.toolchains["//ll:toolchain_type"].local_library_path.path,
            format = "%s/crtn.o",
        )

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
