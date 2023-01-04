"""# `//ll:toolchain.bzl`

This file declares the `ll_toolchain` rule.
"""

load("//ll:attributes.bzl", "LL_TOOLCHAIN_ATTRS")
load("//ll:transitions.bzl", "ll_toolchain_transition")

def _ll_toolchain_impl(ctx):
    # We always need to invoke lld via an ld.lld -> lld symlink.
    lld_alias = ctx.actions.declare_file("ld.lld")
    ctx.actions.symlink(
        output = lld_alias,
        target_file = ctx.executable.linker,
        is_executable = True,
    )

    # TODO: Workaround. Will likely be resolved in the Bazel 6.0 Release.
    if ctx.files.cuda_toolkit != None:
        cuda_toolkit = ctx.files.cuda_toolkit
        cuda_libdir = ctx.actions.declare_symlink("cuda/lib")
        ctx.actions.symlink(
            output = cuda_libdir,
            target_path = "{}/lib".format(Label("@cuda_cudart").workspace_root),
        )
        cuda_nvvm = ctx.actions.declare_symlink("cuda/lib64")
        ctx.actions.symlink(
            output = cuda_nvvm,
            target_path = "{}/nvvm/lib64".format(Label("@cuda_nvcc").workspace_root),
        )
        cuda_bindir = ctx.actions.declare_symlink("cuda/bin")
        ctx.actions.symlink(
            output = cuda_bindir,
            target_path = "{}/bin".format(Label("@cuda_nvcc").workspace_root),
        )
    else:
        cuda_toolkit = []
        cuda_libdir = None
        cuda_bindir = None

    if ctx.file.hipsycl_runtime != None:
        hipsycl_runtime = ctx.actions.declare_file("hipSYCL-rt.so")
        ctx.actions.symlink(
            output = hipsycl_runtime,
            target_file = ctx.file.hipsycl_runtime,
            is_executable = False,
        )
    else:
        hipsycl_runtime = ctx.file.hipsycl_runtime

    if ctx.file.hipsycl_omp_backend != None:
        hipsycl_omp_backend = ctx.actions.declare_file(
            "hipSYCL/rt-backend-omp.so",
        )
        ctx.actions.symlink(
            output = hipsycl_omp_backend,
            target_file = ctx.file.hipsycl_omp_backend,
            is_executable = False,
        )
    else:
        hipsycl_omp_backend = ctx.file.hipsycl_omp_backend

    if ctx.file.hipsycl_cuda_backend != None:
        hipsycl_cuda_backend = ctx.actions.declare_file(
            "hipSYCL/rt-backend-cuda.so",
        )
        ctx.actions.symlink(
            output = hipsycl_cuda_backend,
            target_file = ctx.file.hipsycl_cuda_backend,
            is_executable = False,
        )
    else:
        hipsycl_cuda_backend = ctx.file.hipsycl_cuda_backend

    llvm_project_sources = depset(transitive = [
        data[OutputGroupInfo].compilation_prerequisites_INTERNAL_
        for data in ctx.attr.llvm_project_deps
    ])
    llvm_project_artifacts = ctx.files.llvm_project_deps

    return [
        platform_common.ToolchainInfo(
            c_driver = ctx.executable.c_driver,
            cov = ctx.executable.cov,
            cpp_driver = ctx.executable.cpp_driver,
            archiver = ctx.executable.archiver,
            bitcode_linker = ctx.executable.bitcode_linker,
            linker = lld_alias,
            linker_executable = ctx.executable.linker,
            linker_wrapper = ctx.executable.linker_wrapper,
            address_sanitizer = ctx.files.address_sanitizer,
            leak_sanitizer = ctx.files.leak_sanitizer,
            memory_sanitizer = ctx.files.memory_sanitizer,
            profdata = ctx.executable.profdata,
            profile = ctx.files.profile,
            thread_sanitizer = ctx.files.thread_sanitizer,
            undefined_behavior_sanitizer = ctx.files.undefined_behavior_sanitizer,
            offload_bundler = ctx.executable.offload_bundler,
            offload_packager = ctx.executable.offload_packager,
            builtin_includes = ctx.files.builtin_includes,
            cpp_stdlib = ctx.files.cpp_stdlib,
            cpp_stdhdrs = ctx.files.cpp_stdhdrs,
            cpp_abilib = ctx.files.cpp_abilib,
            cpp_abihdrs = ctx.files.cpp_abihdrs,
            compiler_runtime = ctx.files.compiler_runtime,
            unwind_library = ctx.files.unwind_library,
            llvm_project_sources = llvm_project_sources,
            llvm_project_artifacts = llvm_project_artifacts,
            libomp = ctx.files.libomp,
            local_library_path = ctx.file.local_library_path,
            clang_tidy = ctx.executable.clang_tidy,
            clang_tidy_runner = ctx.executable.clang_tidy_runner,
            symbolizer = ctx.executable.symbolizer,
            machine_code_tool = ctx.executable.machine_code_tool,
            cuda_toolkit = cuda_toolkit,
            cuda_libdir = cuda_libdir,
            cuda_bindir = cuda_bindir,
            cuda_nvvm = cuda_nvvm,
            hip_libraries = ctx.files.hip_libraries,
            hipsycl_plugin = ctx.file.hipsycl_plugin,
            hipsycl_runtime = hipsycl_runtime,
            hipsycl_omp_backend = hipsycl_omp_backend,
            hipsycl_cuda_backend = hipsycl_cuda_backend,
            hipsycl_hip_backend = ctx.files.hipsycl_hip_backend,
            hipsycl_hdrs = ctx.files.hipsycl_hdrs,
        ),
    ]

ll_toolchain = rule(
    implementation = _ll_toolchain_impl,
    executable = False,
    attrs = LL_TOOLCHAIN_ATTRS,
)
