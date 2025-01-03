"""# `//ll:args.bzl`

The functions that create `Args` for use in rule actions.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("//ll:llvm_project_deps.bzl", "LINUX_DEFINES")

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

    If the file is not in an `llvm/include` directory, returns `None`.
    """
    filepath = file.path
    if filepath.find("/llvm/include/") != -1:
        first_segment = filepath.partition("/llvm/include/")[0]
        out = paths.join(first_segment, "llvm/include")
        return out

    return None

def _construct_clang_include_path(file):
    """Construct the paths to LLVM include directories.

    This function looks at a file, and strips everything after "clang/include",
    so that the returned path is "<some_leading_path>/clang/include". This lets
    us handle outputs in transitioned output directories.

    If the file is not in a `clang/include` directory, returns `None`.
    """
    filepath = file.path
    if filepath.find("/clang/include/") != -1:
        first_segment = filepath.partition("/clang/include/")[0]
        out = paths.join(first_segment, "clang/include")
        return out

    return None

def _construct_lld_include_path(file):
    """Construct the paths to LLVM include directories.

    This function looks at a file, and strips everything after "clang/include",
    so that the returned path is "<some_leading_path>/clang/include". This lets
    us handle outputs in transitioned output directories.

    If the file is not in a `clang/include` directory, returns `None`.
    """
    filepath = file.path
    if filepath.find("/lld/include/") != -1:
        first_segment = filepath.partition("/lld/include/")[0]
        out = paths.join(first_segment, "lld/include")
        return out

    return None

def _create_module_import(interface):
    return "{}={}".format(interface.module_name, interface.bmi.path)

def _get_dirname(file):
    """Returns file.dirname."""
    return file.dirname

def _get_basename(file):
    """Returns file.dirname."""
    return file.basename

def _get_rpath_appendix(file):
    "Step back $ORIGIN to the workspace root and then step forward to the file."
    backsteps_to_workspace_root = "/.." * (
        len(file.short_path.split("/")) -
        len(file.owner.package.split("/"))
    )
    return paths.join(
        backsteps_to_workspace_root,
        file.owner.workspace_root,
        file.owner.package,
        file.owner.name,
    )

def compile_object_args(
        ctx,
        in_file,
        out_file,
        cdf,
        defines,
        includes,
        angled_includes,
        bmis):
    """Construct `Args` for compile actions.

    Args:
        ctx: The rule context.
        in_file: The input file to compile.
        out_file: The output file.
        cdf: A file to store the compilation database fragment.
        defines: A `depset` of defines for the target. Added with `-D`.
        includes: A `depset` of includes for the target. Added with `-iquote`.
        angled_includes: A `depset` of angled includes for the target. Added with
            `-I`.
        bmis: A `depset` of tuples `(interface, name)`, each consisting of a
            binary module interface `interface` and a module name `name`. Added
            in a scheme resembling `-fmodule-file=name=interface`.

    Returns:
        An `Args` object.
    """

    toolchain = ctx.toolchains["//ll:toolchain_type"]

    args = ctx.actions.args()

    if ctx.attr.compilation_mode == "cuda_nvptx_nvcc":
        args.add("--forward-unknown-to-host-compiler")
        args.add("--compiler-bindir")
        args.add(toolchain.cpp_driver)

    args.add("-fcolor-diagnostics")

    # Reproducibility.
    args.add("-Wdate-time")
    args.add("-no-canonical-prefixes")
    args.add("-fdebug-compilation-dir=.")
    args.add("-fcoverage-compilation-dir=.")

    # Visualization.
    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("-v")
        args.add("-Xarch_host", "-glldb")

        if ctx.attr.compilation_mode in [
            "cuda_nvptx",
            "hip_nvptx",
        ]:
            args.add_all(["-Xarch_device", "-gdwarf-2"])
            args.add("--cuda-noopt-device-debug")

    # Instrumentation.
    has_sanitizers = (ctx.attr.sanitize != [] and ctx.attr.sanitize != ["none"])

    if "address" in ctx.attr.sanitize and "leak" in ctx.attr.sanitize:
        fail("AddressSanitizer and LeakSanitizer are mutually exclusive.")

    if has_sanitizers or ctx.coverage_instrumented:
        args.add("-fno-omit-frame-pointer")
        args.add_all(["-Xarch_host", "-glldb"])
        args.add_all(["-Xarch_host", "-gdwarf-5"])

        if ctx.attr.compilation_mode in [
            "cuda_nvptx",
            "hip_nvptx",
        ]:
            args.add_all(["-Xarch_device", "-gdwarf-2"])
            args.add("--cuda-noopt-device-debug")

            for file in ctx.files.experimental_device_intrinsics:
                args.add("-Xarch_device")
                args.add(file.path, format = "-include%s")

    if ctx.coverage_instrumented and ctx.attr.compilation_mode != "bootstrap":
        args.add_all(["-fprofile-instr-generate", "-fcoverage-mapping"])

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
        "cuda_nvptx",
        "hip_amdgpu",
        "hip_nvptx",
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
        "cuda_nvptx",
        "hip_amdgpu",
        "hip_nvptx",
    ]:
        args.add("--offload-new-driver")

    if ctx.attr.compilation_mode in [
        "cuda_nvptx",
        "hip_nvptx",
    ]:
        # Enable the use of libc++ for the clang-based device compilation.
        # This is only used with the clang-based device compilation. The
        # cuda_nvptx_nvcc toolchain uses libstdc++ from Nix.
        args.add("-D_ALLOW_UNSUPPORTED_LIBCPP")

        args.add("-Wno-unknown-cuda-version")  # Will always be unknown.
        args.add("-xcuda")
        if toolchain.LL_CUDA_TOOLKIT != "":
            args.add(toolchain.LL_CUDA_TOOLKIT, format = "--cuda-path=%s")

    if ctx.attr.compilation_mode == "cuda_nvptx_nvcc":
        args.add("--x")
        args.add("cu")

        # Upstream Clang is always "unsupported".
        args.add("--allow-unsupported-compiler")

        # Ensure clang doesn't build device code.
        args.add("--cuda-host-only")

        if toolchain.LL_CUDA_TOOLKIT != "":
            args.add(toolchain.LL_CUDA_TOOLKIT, format = "-I%s/include")

    if ctx.attr.compilation_mode in [
        "hip_nvptx",
        "hip_amdgpu",
    ]:
        args.add_all(
            [
                Label("@hip").workspace_root,
                paths.join(Label("@clr").workspace_root, "hipamd"),
            ],
            format_each = "-I%s/include",
        )

    clang_resource_dir = paths.join(llvm_bindir_path(ctx), "clang/staging")

    if ctx.attr.compilation_mode == "hip_amdgpu":
        args.add("-xhip")
        args.add(toolchain.hip_runtime[0].path, format = "--rocm-path=%s")
        args.add(clang_resource_dir, format = "-isystem%s")
        args.add(
            toolchain.rocm_device_libs[0].dirname,  # .../amdgcn/bitcode
            format = "--rocm-device-lib-path=%s",
        )

    # Write compilation database.
    args.add("-Xarch_host")
    args.add(cdf, format = "-MJ%s")

    # Environment encapsulation.
    args.add("-nostdinc")
    args.add("--gcc-toolchain=NONE")

    # Builtin includes.
    args.add(clang_resource_dir, format = "-resource-dir=%s")
    if in_file.extension != "pcm":
        args.add(clang_resource_dir, format = "-idirafter%s/include")

    # Includes. This reflects the order in which clang will search for included
    # files. Objects compiled from BMIs already contain these from the
    # precompilation step.
    if in_file.extension != "pcm":
        # 0. Search the directory of the including source file for quoted
        #    includes.

        # 1. Search directories specified via -iquote for quoted includes.
        args.add_all(includes, format_each = "-iquote%s", uniquify = True)

        # 2. Search directories specified via -I for quoted and angled includes.
        args.add_all(angled_includes, format_each = "-I%s", uniquify = True)

        # 3. Search directories specified via -isystem for quoted and angled
        #    includes. This is not exposed via target attributes.

        if ctx.attr.compilation_mode == "cuda_nvptx_nvcc":
            if toolchain.LL_CUDA_NVCC_CFLAGS != "":
                args.add_all(
                    toolchain.LL_CUDA_NVCC_CFLAGS.split(":"),
                    omit_if_empty = True,
                )

        llvm_workspace_root = Label("@llvm-project").workspace_root
        args.add_all(
            [
                # TODO: Ugly. Find a better solution.
                paths.join(
                    ctx.var["GENDIR"],  # For __config_site
                    llvm_workspace_root,
                    "libcxx/include",
                ),
                paths.join(llvm_workspace_root, "libcxx/include"),
                paths.join(llvm_workspace_root, "libcxxabi/include"),
                paths.join(llvm_workspace_root, "libunwind/include"),
            ],
            # Force removal of the previous -I includes and adjust them to
            # become system includes.
            format_each = "-isystem%s",
        )

        if toolchain.LL_CFLAGS != "":
            args.add_all(toolchain.LL_CFLAGS.split(":"))

        if ctx.attr.compilation_mode in [
            "hip_amdgpu",
            "hip_nvptx",
        ]:
            if toolchain.LL_AMD_INCLUDES != "":
                args.add_all(toolchain.LL_AMD_INCLUDES.split(":"))

        # 4. Search directories specified via -idirafter for quoted and angled
        #    includes. Since most users will not need this flag, there is no
        #    attribute for it. For non-LLVM related include paths, users should
        #    specify these in the compile_flags attribute.
        if ctx.attr.depends_on_llvm:
            args.add_all(
                toolchain.llvm_project_sources,
                map_each = _construct_llvm_include_path,
                format_each = "-idirafter%s",
                uniquify = True,
                omit_if_empty = True,
            )
            args.add_all(
                toolchain.llvm_project_sources,
                map_each = _construct_clang_include_path,
                format_each = "-idirafter%s",
                uniquify = True,
                omit_if_empty = True,
            )
            args.add_all(
                toolchain.llvm_project_sources,
                map_each = _construct_lld_include_path,
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

    # Always disable transitive includes for libcxx headers.
    args.add("-D_LIBCPP_REMOVE_TRANSITIVE_INCLUDES")

    # TODO: Module precompilations embed absolute paths in precompiled binaries.
    # We use this workaround to prevent abi_tag attribute redeclaration errors
    # in libcxx/include/__bit_reference. We need to figure out how we can
    # re-enable abi-tagging.
    args.add("-D_LIBCPP_NO_ABI_TAG")

    # Additional compile flags.
    args.add_all(ctx.attr.compile_flags)
    for flags in ctx.attr.compile_string_flags:
        args.add_all(flags[BuildSettingInfo].value.split(":"))

    # Load modules conditionally by declaring the module name.
    args.add_all(
        bmis,
        map_each = _create_module_import,
        format_each = "-fmodule-file=%s",
        uniquify = True,
        omit_if_empty = True,
    )

    if ctx.attr.compilation_mode != "bootstrap":
        args.add_all(
            toolchain.cpp_stdmodules,
            map_each = _create_module_import,
            format_each = "-fmodule-file=%s",
        )

    # Input file.
    args.add(in_file)

    # Output file.
    args.add("-o", out_file)

    return [args]

def link_executable_args(ctx, in_files, out_file, mode):
    """Construct `Args` for link actions.

    Args:
        ctx: The rule context.
        in_files: A `depset` of input files.
        out_file: The output file.
        mode: Either `"executable"` or `"shared_object"`, depending on the
            desired output type.

    Returns:
        An `Args` object.
    """
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    args = ctx.actions.args()

    # Provide host and device linker info to clang-linker-wrapper.
    if toolchain.LL_CUDA_TOOLKIT != "":
        # TODO: Incorrectly sets this even when the cuda path is empty.
        args.add(toolchain.LL_CUDA_TOOLKIT, format = "--cuda-path=%s")

    args.add("--host-triple=x86_64-pc-linux-gnu")
    args.add("--linker-path={}".format(toolchain.linker.path))

    args.add("--color-diagnostics")

    # Encapsulation.
    args.add("--nostdlib")

    # Visualization.
    if ctx.var["COMPILATION_MODE"] == "dbg":
        args.add("--verbose")

    if toolchain.LL_LDFLAGS != "":
        args.add_all(toolchain.LL_LDFLAGS.split(":"))

    if ctx.attr.compilation_mode in ["hip_amdgpu"]:
        if toolchain.LL_AMD_LIBRARIES != "":
            args.add_all(toolchain.LL_AMD_LIBRARIES.split(":"))

    # Startup files.
    if mode == "executable":
        args.add(
            "-l:Scrt1.o",
            "-l:crti.o",
        )

    # Instrumentation.
    has_sanitizers = (ctx.attr.sanitize != [] and ctx.attr.sanitize != ["none"])

    if has_sanitizers or ctx.coverage_instrumented:
        args.add("--eh-frame-hdr")
        args.add("--whole-archive")

    if ctx.coverage_instrumented and ctx.attr.compilation_mode != "bootstrap":
        args.add_all(toolchain.profile)

    if "address" in ctx.attr.sanitize and "leak" in ctx.attr.sanitize:
        fail("AddressSanitizer and LeakSanitizer are mutually exclusive.")

    if "address" in ctx.attr.sanitize:
        args.add_all(toolchain.address_sanitizer)

    if "leak" in ctx.attr.sanitize:
        args.add_all(toolchain.leak_sanitizer)

    if "memory" in ctx.attr.sanitize:
        args.add_all(toolchain.memory_sanitizer)

    if "thread" in ctx.attr.sanitize:
        args.add_all(toolchain.thread_sanitizer)

    if "undefined_behavior" in ctx.attr.sanitize:
        args.add_all(
            toolchain.undefined_behavior_sanitizer,
        )

    if has_sanitizers or ctx.coverage_instrumented:
        args.add("--no-whole-archive")

    # Add dynamic linker. When in a nix env, make sure to use the nix variant.
    if toolchain.LL_DYNAMIC_LINKER != "":
        args.add(toolchain.LL_DYNAMIC_LINKER, format = "--dynamic-linker=%s")
    else:
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

    if ctx.attr.compilation_mode in [
        "cuda_nvptx",
        "cuda_nvptx_nvcc",
        "hip_nvptx",
    ]:
        # Both the CUDA driver and the CUDA toolkit contain `libcuda.so`.
        # Link against `<cudatoolkit>/lib/libcuda.so` at build time, but make
        # sure that `<cudadriver>/lib/libcuda.so` takes precedence at runtime.
        if toolchain.LL_CUDA_DRIVER != "":
            args.add(toolchain.LL_CUDA_DRIVER, format = "-rpath=%s/lib")

        if toolchain.LL_CUDA_TOOLKIT != "":
            args.add(toolchain.LL_CUDA_TOOLKIT, format = "-rpath=%s/lib")
            args.add(toolchain.LL_CUDA_TOOLKIT, format = "-L%s/lib")
            args.add(toolchain.LL_CUDA_TOOLKIT, format = "-L%s/lib/stubs")

        args.add("-lcuda")
        args.add("-lcudart")
        args.add("-lcupti")
    if ctx.attr.compilation_mode == "hip_amdgpu":
        args.add(toolchain.hip_runtime[0].dirname, format = "-L%s")
        args.add(toolchain.hip_runtime[0].basename, format = "-l:%s")
        hip_runtime_rpath = paths.join(
            "{}.runfiles".format(ctx.label.name),
            ctx.workspace_name,
            paths.dirname(toolchain.hip_runtime[0].short_path),
        )
        args.add(
            hip_runtime_rpath,
            format = "-rpath=$ORIGIN/%s",
        )

    # Additional system libraries.
    args.add("-lm")  # Math.
    args.add("-ldl")  # Dynamic linking.
    args.add("-lpthread")  # Thread support.
    args.add("-lc")  # Glibc.

    # Target-specific flags.
    if mode == "executable":
        args.add_all(ctx.attr.link_flags)
        for flags in ctx.attr.link_string_flags:
            args.add_all(flags[BuildSettingInfo].value.split(":"))
    elif mode == "shared_object":
        args.add_all(ctx.attr.shared_object_link_flags)

        for flags in ctx.attr.shared_object_link_string_flags:
            args.add_all(flags[BuildSettingInfo].value.split(":"))

        if ctx.file.version_script != None:
            args.add(ctx.file.version_script, format = "--version-script=%s")
    else:
        fail("Invalid linking mode")

    # Add archives and objects.
    args.add_all(
        [
            file
            for file in in_files.to_list()
            if file.extension in ["a", "o"]
        ],
        omit_if_empty = True,
    )

    if ctx.attr.compilation_mode == "cuda_nvptx_nvcc":
        if toolchain.LL_CUDA_NVCC_LDFLAGS != "":
            args.add_all(
                toolchain.LL_CUDA_NVCC_LDFLAGS.split(":"),
                omit_if_empty = True,
            )

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
        map_each = _get_rpath_appendix,
        format_each = "-rpath=$ORIGIN%s",
        uniquify = True,
        omit_if_empty = True,
    )

    # End files.
    if mode == "executable":
        args.add("-l:crtn.o")

    args.add("-o", out_file)

    return [args]

def create_archive_library_args(ctx, in_files, out_file):
    """Construct `Args` for archive actions.

    Uses `-cqL` for regular archiving and `-vqL` for debug builds.

    Args:
        ctx: The rule context.
        in_files: A `depset` of input files.
        out_file: The output file.

    Returns:
        An `Args` object.
    """
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
