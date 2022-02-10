load("@bazel_skylib//lib:paths.bzl", "paths")
load("//ll:args.bzl", "construct_default_args")
load("//ll:providers.bzl", "LlInfo")

def resolve_deps(ctx):
    dep_headers = [dep[LlInfo].transitive_headers for dep in ctx.attr.deps]
    dep_libraries = [dep[LlInfo].libraries for dep in ctx.attr.deps]
    dep_defines = [dep[LlInfo].transitive_defines for dep in ctx.attr.deps]
    dep_includes = [dep[LlInfo].transitive_includes for dep in ctx.attr.deps]

    return dep_headers, dep_libraries, dep_defines, dep_includes

def create_compile_inputs(ctx):
    dep_headers, dep_libraries, dep_defines, dep_includes = resolve_deps(ctx)

    transitive_headers = depset(
        ctx.files.transitive_hdrs,
        transitive = dep_headers,
    )
    headers = depset(ctx.files.hdrs, transitive = [transitive_headers])

    libraries = depset([], transitive = dep_libraries)

    transitive_defines = depset(
        ctx.attr.transitive_defines,
        transitive = dep_defines,
    )
    defines = depset(ctx.attr.defines, transitive = [transitive_defines])

    transitive_includes = depset(
        ctx.attr.transitive_includes,
        transitive = dep_includes,
    )
    includes = depset(ctx.attr.includes, transitive = [transitive_includes])

    return (
        headers,
        libraries,
        defines,
        includes,
        transitive_headers,
        transitive_defines,
        transitive_includes,
    )

def _get_dirname(file):
    return file.dirname

def expose_headers(ctx):
    headers_to_expose = ctx.files.transitive_hdrs
    exposed_hdrs = []

    for hdr in headers_to_expose:
        args = ctx.actions.args()

        args.add(hdr)

        build_file_path = paths.join(
            ctx.label.workspace_root,
            paths.dirname(ctx.build_file_path),
        )
        relative_hdr_path = paths.relativize(hdr.path, build_file_path)
        exposed_hdr = ctx.actions.declare_file(relative_hdr_path)

        args.add(exposed_hdr.dirname)

        ctx.actions.run_shell(
            outputs = [exposed_hdr],
            inputs = [hdr],
            command = "cp $1 $2",
            arguments = [args],
            mnemonic = "LlCopyExposedHeaders",
            use_default_shell_env = False,
        )
        exposed_hdrs += [exposed_hdr]
    return exposed_hdrs

def compile_objects(
        ctx,
        headers = [],
        defines = [],
        includes = [],
        toolchain_type = "//ll:toolchain_type"):
    compilable_extensions = ["c", "cpp", "S"]
    compilable_srcs = [
        src
        for src in ctx.files.srcs
        if src.extension in compilable_extensions
    ]
    intermediary_objects = []

    for src in compilable_srcs:
        args = construct_default_args(ctx, headers, includes, defines)

        args.add_all(ctx.attr.compile_flags)

        # Single input.
        args.add(src)

        # Construct the correct output path for the object file.
        build_file_path = paths.join(
            ctx.label.workspace_root,
            paths.dirname(ctx.build_file_path),
        )
        relative_src_path = paths.relativize(src.path, build_file_path)
        relative_src_dir = paths.dirname(relative_src_path)
        intermediary_object = ctx.actions.declare_file(
            paths.join(relative_src_dir, paths.replace_extension(src.basename, ".o")),
        )
        args.add("-c")
        args.add("-o", intermediary_object)

        # Explicitly specify builtin includes.
        args.add("-nobuiltininc")
        staging_include = "bazel-out/k8-fastbuild/bin/external/llvm-project/clang/staging/include"
        args.add("-isystem{}".format(staging_include))

        if toolchain_type == "//ll:toolchain_type":
            inputs = depset(
                ctx.files.srcs +
                ctx.toolchains[toolchain_type].builtin_includes +
                ctx.toolchains["//ll:toolchain_type"].cpp_stdlib,
                transitive = [headers],
            )
            libcxx_path = "bazel-out/k8-fastbuild/bin/external/llvm-project/libcxx"
            args.add("-nostdlib")
            args.add("-nostdinc++")
            args.add("-nostdlib++")
            args.add("-I{}".format(libcxx_path + "/include"))
        else:
            # Only used for ll_bootstrap_toolchain.
            inputs = depset(
                ctx.files.srcs +
                ctx.toolchains[toolchain_type].builtin_includes,
                transitive = [headers],
            )

        ctx.actions.run(
            outputs = [intermediary_object],
            inputs = inputs,
            executable = ctx.toolchains[toolchain_type].c_driver,
            arguments = [args],
            mnemonic = "LlCompileIntermediaryObject",
            use_default_shell_env = False,
        )
        intermediary_objects += [intermediary_object]
    return intermediary_objects

def archive_action(
        ctx,
        object_files,
        libraries,
        toolchain_type):
    args = ctx.actions.args()

    # -c: Do not warn when creating a new archive.
    # -v: Verbose.
    # -q: Quick-append inputs.
    # -L: Quick append archive members instead of the archive itself if an
    #     archive is part of the inputs.
    args.add("-cvqL")

    out_file = ctx.actions.declare_file(ctx.label.name + ".a")
    args.add(out_file)

    args.add_all(object_files)
    args.add_all(libraries)

    ctx.actions.run(
        outputs = [out_file],
        inputs = depset(object_files, transitive = [libraries]),
        executable = ctx.toolchains[toolchain_type].archiver,
        arguments = [args],
        mnemonic = "LlArchiveObject",
        use_default_shell_env = False,
    )
    return out_file

def create_archive_library(
        ctx,
        headers = [],
        libraries = [],
        defines = [],
        includes = [],
        toolchain_type = "//ll:toolchain_type"):
    intermediary_objects = compile_objects(
        ctx,
        headers = headers,
        defines = defines,
        includes = includes,
        toolchain_type = toolchain_type,
    )
    archive = archive_action(
        ctx,
        object_files = intermediary_objects,
        libraries = libraries,
        toolchain_type = toolchain_type,
    )
    return archive

def create_executable(
        ctx,
        headers = [],
        libraries = [],
        defines = [],
        includes = [],
        toolchain_type = "//ll:toolchain_type"):
    intermediary_objects = compile_objects(
        ctx,
        headers = headers,
        defines = defines,
        includes = includes,
        toolchain_type = toolchain_type,
    )

    args = construct_default_args(ctx, headers, includes, defines)

    # Use ld.lld built from upstream.
    args.add(
        ctx.toolchains[toolchain_type].linker,
        format = "--ld-path=%s",
    )

    args.add_all(ctx.attr.link_flags)

    inputs = depset(intermediary_objects, transitive = [headers, libraries])

    # Set the compiler driver to clang++ if at leaset one of the source files
    # has a c++-related file extension.
    compiler_driver = ctx.toolchains[toolchain_type].c_driver
    for src in ctx.files.srcs:
        if src.extension in ["cpp", "hpp", "ipp"]:
            compiler_driver = ctx.toolchains[toolchain_type].cpp_driver
            break

    # Overwrite the default C++ library if not bootstrapping.
    # When boostrapping libc++ we want to use the host's default C++ library.
    if (toolchain_type == "//ll:toolchain_type"):
        args.add("-nostdlib")

        # Link static per default. The proprietary flag disables this.
        if not ctx.attr.proprietary:
            args.add("--static")

        # Add system libraries.
        args.add("-lm")  # Required for math-related functions.
        args.add("-ldl")  # Required by libunwind.
        args.add("-lpthread")  # Required by libunwind.
        args.add("-lc")  # Required. This is glibc.

        # Use compiler-rt as runtime.
        compiler_rt_path = "bazel-out/k8-fastbuild/bin/external/llvm-project/compiler-rt"
        args.add("-L{}".format(compiler_rt_path))
        args.add("-Wl,-rpath,{}".format(compiler_rt_path))
        args.add("-lll_compiler-rt")

        # Use libunwind as unwinder library.
        libunwind_path = "bazel-out/k8-fastbuild/bin/external/llvm-project/libunwind"
        args.add("-L{}".format(libunwind_path))
        args.add("-lll_unwind")

        # Add local crt1.o, crti.o and crtn.o files.
        args.add_all(ctx.toolchains["//ll:toolchain_type"].local_crt)

        # Disable system libraries.
        args.add("-nostdlib++")

        # Use custom libc++. Note that our libc++ includes libc++abi.
        libcxx_path = "bazel-out/k8-fastbuild/bin/external/llvm-project/libcxx"
        args.add("-isystem{}".format(libcxx_path + "/include"))
        args.add("-L{}".format(libcxx_path))
        args.add("-Wl,-rpath,{}".format(libcxx_path))
        args.add("-lll_cxx")

        # Strip symbols.
        args.add("-Wl,--strip-all")

        inputs = depset(
            ctx.toolchains["//ll:toolchain_type"].compiler_runtime +
            ctx.toolchains["//ll:toolchain_type"].unwind_library +
            ctx.toolchains["//ll:toolchain_type"].cpp_stdlib +
            ctx.toolchains["//ll:toolchain_type"].local_crt,
            transitive = [inputs],
        )

    # Libraries.
    args.add_all(libraries)

    # Sources. These are only object files since any text files would have been
    # compiled by the compile_objects call above.
    args.add_all(intermediary_objects)

    out_file = ctx.actions.declare_file(ctx.label.name)

    args.add("-o", out_file)

    ctx.actions.run(
        outputs = [out_file],
        inputs = inputs,
        executable = compiler_driver,
        tools = [ctx.toolchains[toolchain_type].linker],
        arguments = [args],
        mnemonic = "LlLinkObject",
        use_default_shell_env = False,
    )
    return out_file
