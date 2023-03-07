"""# `//third-party-overlays:defs.bzl`

A custom `opencl_bitcode_library` target for the `rocm-device-libs`.
"""

load("@rules_ll//ll:environment.bzl", "compile_object_environment")
load("@rules_ll//ll:args.bzl", "llvm_bindir_path")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_ll//ll:transitions.bzl", "transition_to_bootstrap")

CLANG_OCL_FLAGS = [
    "-xcl",
    "-Xclang",
    "-cl-std=CL2.0",
    "-target",
    "amdgcn-amd-amdhsa",
    "-fvisibility=protected",
    "-fomit-frame-pointer",
    "-Xclang",
    "-finclude-default-header",
    "-Xclang",
    "-fexperimental-strict-floating-point",
    "-nogpulib",
    "-cl-no-stdinc",
]

def _opencl_bitcode_library_impl(ctx):
    toolchain = ctx.toolchains["@rules_ll//ll:toolchain_type"]
    intermediaries = []

    # 1. Use clang to build the intermediary bitcode objects.
    for file in ctx.files.srcs:
        build_file_path = paths.join(
            ctx.label.workspace_root,
            paths.dirname(ctx.build_file_path),
        )
        relative_src_path = paths.relativize(file.path, build_file_path)
        relative_src_dir = paths.dirname(relative_src_path)
        intermediary_bitcode = ctx.actions.declare_file(
            paths.join(
                relative_src_dir,
                paths.replace_extension(file.basename, ".bc"),
            ),
        )

        args = ctx.actions.args()
        args.add("-fcolor-diagnostics")
        args.add("-nostdinc")

        # Reproducibility.
        args.add("-Wdate-time")
        args.add("-no-canonical-prefixes")
        args.add("-fdebug-compilation-dir=.")

        clang_resource_dir = paths.join(llvm_bindir_path(ctx), "clang/staging")
        args.add(clang_resource_dir, format = "-resource-dir=%s")
        args.add(clang_resource_dir, format = "-idirafter%s/include")

        args.add_all(
            CLANG_OCL_FLAGS + [
                "-c",
                "-emit-llvm",
                "-Xclang",
                "-mlink-builtin-bitcode",
                "-Xclang",
                ctx.file.irif,
                file,
                "-o",
                intermediary_bitcode,
            ],
        )

        for hdr in ctx.files.hdrs:
            args.add(hdr.dirname, format = "-I%s")

        ctx.actions.run(
            outputs = [intermediary_bitcode],
            inputs = [file] + ctx.files.hdrs,
            executable = toolchain.cpp_driver,
            arguments = [args],
            tools = [ctx.file.irif] + toolchain.builtin_includes,
            use_default_shell_env = False,
            env = compile_object_environment(ctx),
        )
        intermediaries.append(intermediary_bitcode)

    # 2. Add .ll files directly to the intermediaries.
    for file in ctx.files.bitcode_srcs:
        intermediaries.append(file)

    # 3. Naively link all intermediary files
    link_zero = ctx.actions.declare_file(ctx.label.name + ".link0.lib.bc")

    ctx.actions.run(
        outputs = [link_zero],
        inputs = intermediaries,
        executable = toolchain.bitcode_linker,
        arguments = [ctx.actions.args().add_all(["-o", link_zero] + intermediaries)],
        use_default_shell_env = False,
    )

    # 4. Link internal bitcode libraries.
    link_internal = ctx.actions.declare_file(ctx.label.name + ".lib.bc")
    ctx.actions.run(
        outputs = [link_internal],
        inputs = [link_zero],
        executable = toolchain.bitcode_linker,
        arguments = [ctx.actions.args().add_all(
            [
                "-internalize",
                "-only-needed",
                "-o",
                link_internal,
                link_zero,
            ],
        )],
        use_default_shell_env = False,
    )

    # 5. Run the AMD opt pipeline.
    optimized = ctx.actions.declare_file(ctx.label.name + ".strip.bc")
    ctx.actions.run(
        outputs = [optimized],
        inputs = [link_internal],
        executable = toolchain.opt,
        arguments = [ctx.actions.args().add_all([
            "-passes=amdgpu-unify-metadata,strip",
            "-o",
            optimized,
            link_internal,
        ])],
        use_default_shell_env = False,
    )

    # 6. Run the prepare-builtins tool.
    out_file = ctx.actions.declare_file("amdgcn/bitcode/" + ctx.label.name + ".bc")
    ctx.actions.run(
        outputs = [out_file],
        inputs = [optimized],
        executable = ctx.executable.prepare_builtins,
        arguments = [ctx.actions.args().add_all([
            "-o",
            out_file,
            optimized,
        ])],
        use_default_shell_env = False,
    )

    return [
        DefaultInfo(
            files = depset([out_file]),
        ),
    ]

opencl_bitcode_library = rule(
    implementation = _opencl_bitcode_library_impl,
    toolchains = ["@rules_ll//ll:toolchain_type"],
    attrs = {
        "hdrs": attr.label_list(
            allow_files = True,
        ),
        "srcs": attr.label_list(
            allow_files = [".cl"],
        ),
        "bitcode_srcs": attr.label_list(
            allow_files = [".ll"],
        ),
        "toolchain_configuration": attr.label(
            default = "@rules_ll//ll:current_ll_toolchain_configuration",
        ),
        "irif": attr.label(
            allow_single_file = True,
            default = "@rocm-device-libs//:irif",
        ),
        "prepare_builtins": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = transition_to_bootstrap,
            default = "@rocm-device-libs//:prepare-builtins",
        ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        ),
    },
)
