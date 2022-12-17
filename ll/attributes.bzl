"""# `//ll:attributes.bzl`

Attribute dictionaries for `ll_*` rules.
"""

load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("//ll:providers.bzl", "LlInfo")
load("//ll:llvm_project_deps.bzl", "LLVM_PROJECT_DEPS")
load(
    "//ll:transitions.bzl",
    "transition_to_bootstrap",
    "transition_to_cpp",
)

DEFAULT_ATTRS = {
    "angled_includes": attr.string_list(
        doc = """Additional angled include paths for this target.

        Per default all inclusions are quoted includes (via ``-iquote``).
        Paths added here are available as angled includes (via ``-I``).

        Only used for this target.
        """,
    ),
    "compilation_mode": attr.string(
        doc = """Enables compilation of heterogeneous single source files.

        WARNING: VERY EXPERIMENTAL.

        Prefer using this attribute over adding SYCL/HIP/CUDA flags manually in
        the `compile_flags` and `link_flags`.

        See <TODO: GUIDE> for a detailed explanation of how this flag changes
        the generated command line arguments/compile passes.

        `"cpp"` will treat compilable sources as regular C++.

        `"cuda_nvidia"` will treat compilable sources as CUDA kernels.

        `"hip_nvidia"` will treat compilable sources as HIP kernels.

        `"omp_cpu"` will enable OpenMP CPU support. Equivalent to adding
        `-fopenmp` to `compile_flags` and `@llvm-project//openmp:libomp` to
        `deps`.

        `"sycl_cpu"` will enable SYCL CPU support using hipSYCL with the OpenMP
        backend. Don't use this. It's not fully implemented yet.

        `"sycl_cuda"` will enable highly experimental SYCL CUDA support using
        hipSYCL. Don't use this. It's not fully implemented yet.

        `"bootstrap"` is used for the internal dependencies of the
            `ll_toolchain` such as `libcxxabi` etc.
        """,
        default = "cpp",
        # TODO: hip_amd, sycl_amd
        values = [
            "cpp",
            "omp_cpu",
            "cuda_nvidia",
            "hip_nvidia",
            "sycl_cpu",
            "sycl_cuda",
            "bootstrap",
        ],
    ),
    "compile_flags": attr.string_list(
        doc = """Additional flags for the compiler.

        A list of strings `["-O3", "-std=c++20"]` will be appended to the
        compile command line arguments as `-O3 -std=c++20`.

        Flag pairs like `-Xclang -somearg` need to be split into separate flags
        `["-Xclang", "-somearg"]`.

        Only used for this target.
        """,
    ),
    "depends_on_llvm": attr.bool(
        doc = """Whether this target directly depends on targets from the
        `llvm-project-overlay`.

        Setting this to `True` will make the `cc_library` targets from the LLVM
        project overlay available to this target. Compile actions add
        `-idirafter` include paths to `clang/include` and `llvm/include` for
        Clang/LLVM internal and generated headers so that they can be used
        without setting any additional flags.
        """,
        default = False,
    ),
    "data": attr.label_list(
        doc = """Additional files made available to the sandboxed actions
        executed within this rule. These files aren't appended to the default
        line arguments, but are part of the inputs to the actions and may be
        added to command line arguments manually via the `includes`,
        and `compile_flags` (for `ll_binary` also `link_flags`) attributes.

        This attribute may be used to make intermediary outputs from non-ll
        targets (for example from `rules_cc` or `filegroup`) available to the
        rule.
        """,
        allow_files = True,
    ),
    "defines": attr.string_list(
        doc = """Additional defines for this target.

        A list of strings `["MYDEFINE_1", "MYDEFINE_2"]` will add
        `-DMYDEFINE_1 -DMYDEFINE_2` to the compile command line.

        Only used for this target.
        """,
    ),
    "deps": attr.label_list(
        doc = """The dependencies for this target.

        Every dependency needs to be an `ll_library`.""",
        providers = [LlInfo],
    ),
    "exposed_angled_includes": attr.string_list(
        doc = """Additional exposed angled include paths for this target.

        Includes in this attribute will be added to the compile command line
        arguments for direct dependents.
        """,
    ),
    "exposed_defines": attr.string_list(
        doc = """Additional exposed defines for this target.

        These defines will be defined in the compile actions of direct
        dependents.
        """,
    ),
    "exposed_hdrs": attr.label_list(
        doc = """Exposed headers for this target.

        Exposed headers are available to depending downstream targets. This is
        the place to put the public API headers for a library.
        """,
        allow_files = True,
    ),
    "exposed_includes": attr.string_list(
        doc = """Additional exposed include paths for this target.

        Includes in this attribute will be added to the compile command line
        arguments for direct dependents.
        """,
    ),
    "exposed_interfaces": attr.label_keyed_string_dict(
        doc = """Transitive interfaces for this target.

        Like `interfaces`, but both the precompiled modules and the compiled
        objects derived from files in this attribute are exposed. Files in
        this attribute can see BMIs from modules in `interfaces`. Primary
        module interfaces should go here.
        """,
        allow_files = [".cppm", ".cpp", ".cc"],
    ),
    "exposed_relative_angled_includes": attr.string_list(
        doc = """Additional exposed angled include paths, relative to the
        original target workspace.

        Includes in this attribute will be added to the compile command line
        arguments for direct dependents.
        """,
    ),
    "exposed_relative_includes": attr.string_list(
        doc = """Additional exposed include paths, relative to the original
        target workspace.

        Includes in this attribute will be added to the compile command line
        arguments for direct dependents.
        """,
    ),
    "hdrs": attr.label_list(
        doc = """Header files for this target.

        Headers in this attribute won't be exported. Any generated include paths
        are only used for this target and the header files aren't made available
        to downstream targets.

        When including header files as `#include "some/path/myheader.h"` their
        include paths need to be specified in the `includes` attribute as well.
        """,
        allow_files = True,
    ),
    "includes": attr.string_list(
        doc = """Additional quoted include paths for this target.

        When including a header not via `#include "header.h"`, but via
        `#include "subdir/header.h"`, the include path needs to be added here in
        addition to making the header available in the `hdrs` attribute.

        Only used for this target.
        """,
    ),
    "interfaces": attr.label_keyed_string_dict(
        doc = """Module interfaces for this target.

        See [C++ modules](../guides/modules.md) for usage instructions.

        Internally, interfaces will be precompiled and then compiled to objects
        named `<filename>.interface.o`. This way object files for modules
        implemented via separate interfaces and implementations (such as `A.cpp`
        in `srcs` and `A.cppm` in `interfaces`) don't clash.

        Files in the same `interfaces` attribute can't see each other's BMIs,
        which means that multiple `ll_library` targets may be required to build
        a module. (For instance, if a module partition is used by other module
        partitions.)

        The BMIs in `interfaces` are visible to `exposed_interfaces`. This way
        we can often get away with putting all module partitions in `interfaces`
        and the primary module interface in `exposed_interfaces`.
        """,
        allow_files = [".cppm"],
    ),
    "relative_angled_includes": attr.string_list(
        doc = """Additional angled include paths, relative to the target
        workspace.

        This attribute is useful if we require custom include prefix stripping,
        but have dynamic paths, such as ones generated by ``bzlmod``. So instead
        of using ``angled_includes = ["external/mydep.someversion/include"]`` we
        can use ``relative_angled_includes = ["include"]``, and the path to the
        workspace will be added automatically.

        Only used for this target.
        """,
    ),
    "relative_includes": attr.string_list(
        doc = """Additional quoted include paths, relative to the target
        workspace.

        This attribute is useful if we require custom include prefix stripping,
        but have dynamic paths, such as ones generated by ``bzlmod``. So instead
        of using ``includes = ["external/mydep.someversion/include"]`` we can
        use ``relative_includes = ["include"]``, and the path to the workspace
        will be added automatically.

        Only used for this target.
        """,
    ),
    "sanitize": attr.string_list(
        doc = """Enable sanitizers for this target.

        See the [Sanitizers](../guides/sanitizers.md) guide for usage instructions.

        Some sanitizers come with heavy performance penalties. Many combinations
        of multiple enabled sanitizers are invalid. If possible, use only one at
        a time.

        Since sanitizers find issues during runtime, error reports are
        nondeterministic and not reproducible at an address level. Run sanitized
        executables multiple times and build them with different optimization
        levels to maximize coverage.

        `"address"`: Enable AddressSanitizer to detect memory errors.

        `"leak"`: Enable LeakSanitizer to detect memory leaks.

        `"memory"`: Enable MemorySanitizer to detect uninitialized reads.

        `"undefined_behavior"`: Enable UndefinedBehaviorSanitizer to detect
            undefined behavior.

        `"thread"`: Enable ThreadSanitizer to detect data races.
        """,
    ),
    "srcs": attr.label_list(
        doc = """Compilable source files for this target.

        Only compilable files and object files
        `[".ll", ".o", ".S", ".c", ".cl", ".cpp"]` are allowed here.

        Headers should be placed in the `hdrs` attribute.
        """,
        allow_files = [".ll", ".o", ".S", ".c", ".cc", ".cl", ".cpp", ".cppm", ".cu", ".cxx"],
    ),
    "toolchain_configuration": attr.label(
        doc = """TODO""",
        default = "//ll:current_ll_toolchain_configuration",
    ),
    "_allowlist_function_transition": attr.label(
        default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
    ),
}

LIBRARY_ATTRS = {
    "bitcode_libraries": attr.label_list(
        doc = """Additional bitcode libraries that should be linked to the
        output.

        Only used if `emit` includes `"bitcode"`.
        """,
        allow_files = [".bc"],
    ),
    "bitcode_link_flags": attr.string_list(
        doc = """Additional flags for the bitcode linker when emitting bitcode.

        Only Used if `emit` includes `"bitcode"`.
        """,
    ),
    "emit": attr.string_list(
        doc = """Sets the output mode. Multiple values may be specified.

        `"archive"` invokes the archiver and adds an archive with a `.a`
        extension to the outputs.
        `"shared_object"` invokes the linker and adds a shared object with a
        `.so` extension to the outputs.
        `"bitcode"` invokes the bitcode linker and adds an LLVM bitcode file
        with a `.bc` extension to the outputs.
        `"objects"` adds loose object files to the outputs.
        """,
        default = ["archive"],
    ),
    "shared_object_link_flags": attr.string_list(
        doc = """Additional flags for the linker when emitting shared objects.

        Only used if `emit` includes `"shared_object"`.
        """,
    ),
}

BINARY_ATTRS = {
    "libraries": attr.label_list(
        doc = """Additional libraries linked to the final executable.

        Adds these libraries to the command line arguments for the linker.
        """,
        allow_files = True,
    ),
    "link_flags": attr.string_list(
        doc = """Additional flags for the linker.

        For `ll_binary`:
        This is the place for adding library search paths and external link
        targets.

        Assuming you have a library `/some/path/libmylib.a` on your host system,
        you can make `mylib.a` available to the linker by passing
        `["-L/some/path", "-lmylib"]` to this attribute.

        Prefer using the `libraries` attribute for library files already present
        within the Bazel build graph.
        """,
    ),
}

LL_TOOLCHAIN_ATTRS = {
    "address_sanitizer": attr.label_list(
        doc = """AddressSanitizer libraries.""",
        # default = [
        #     "@llvm-project//compiler-rt/lib/asan:clang_rt.asan",
        #     "@llvm-porject//compiler-rt/lib/asan:clang_rt.asan_cxx",
        # ],
        cfg = transition_to_bootstrap,
    ),
    "archiver": attr.label(
        doc = "The archiver.",
        allow_single_file = True,
        executable = True,
        cfg = transition_to_bootstrap,
        default = "@llvm-project//llvm:llvm-ar",
    ),
    "bitcode_linker": attr.label(
        doc = """The linker for LLVM bitcode files. While `llvm-ar` is able
        to archive bitcode files into an archive, it can't link them into a
        single bitcode file. We need `llvm-link` to do this.
        """,
        executable = True,
        cfg = transition_to_bootstrap,
        default = "@llvm-project//llvm:llvm-link",
    ),
    "builtin_includes": attr.label(
        doc = "Builtin header files. Defaults to @llvm-project//clang:builtin_headers_gen",
        cfg = "target",
        default = "@llvm-project//clang:builtin_headers_gen",
    ),
    "c_driver": attr.label(
        doc = "The C compiler driver.",
        executable = True,
        allow_single_file = True,
        cfg = transition_to_bootstrap,
        default = "@llvm-project//clang:clang",
    ),
    "clang_tidy": attr.label(
        doc = "The clang-tidy executable.",
        cfg = transition_to_bootstrap,
        default = "@llvm-project//clang-tools-extra/clang-tidy:clang-tidy",
        executable = True,
    ),
    "clang_tidy_runner": attr.label(
        doc = "The run-clang-tidy.py wrapper script for clang-tidy. Enables multithreading.",
        cfg = transition_to_bootstrap,
        default = "@llvm-project//clang-tools-extra/clang-tidy:run-clang-tidy",
        executable = True,
    ),
    "compiler_runtime": attr.label_list(
        doc = "The compiler runtime.",
        cfg = transition_to_bootstrap,
        providers = [LlInfo],
    ),
    "cpp_abihdrs": attr.label(
        doc = "The C++ ABI headers.",
        cfg = transition_to_bootstrap,
    ),
    "cpp_abilib": attr.label(
        doc = "The C++ ABI library archive.",
        cfg = transition_to_bootstrap,
        providers = [LlInfo],
    ),
    "cpp_driver": attr.label(
        doc = "The C++ compiler driver.",
        allow_single_file = True,
        executable = True,
        cfg = transition_to_bootstrap,
        default = "@llvm-project//clang:clang++",
    ),
    "cpp_stdhdrs": attr.label(
        doc = "The C++ standard library headers.",
        cfg = transition_to_bootstrap,
        allow_files = True,
    ),
    "cpp_stdlib": attr.label(
        doc = "The C++ standard library archive.",
        cfg = transition_to_bootstrap,
        providers = [LlInfo],
    ),
    "libomp": attr.label(
        doc = "The OpenMP library.",
        cfg = transition_to_cpp,
        providers = [LlInfo],
        # default = "@llvm-project//openmp:libomp",
    ),
    "cuda_toolkit": attr.label_list(
        doc = """CUDA toolkit files. `rules_ll` will still use `clang` as
        the CUDA device compiler. Building targets that make use of the
        CUDA libraries imply acceptance of their respective licenses.
        """,
        # default = [
        #     "@cuda_cudart//:contents",
        #     "@cuda_nvcc//:contents",
        #     "@cuda_nvprof//:contents",
        #     "@libcurand//:contents",
        # ],
        cfg = transition_to_cpp,
    ),
    "hip_libraries": attr.label_list(
        doc = """HIP library files. `rules_ll` will use `clang` as the
        device compiler. Building targets that make use of the HIP toolkit
        implies acceptance of its license.

        Using HIP for AMD devices implies the use of the ROCm stack and the
        acceptance of its licenses.

        Using HIP for Nvidia devices implies use of the CUDA toolkit and the
        acceptance of its licenses.
        """,
        # default = [
        #     "@hip//:headers",
        #     "@hipamd//:headers",
        # ],
        cfg = transition_to_cpp,
    ),
    "hipsycl_plugin": attr.label(
        doc = """TODO""",
        cfg = transition_to_cpp,
        allow_single_file = True,
        # default = ["@hipsycl//hipSYCL_clang"],
    ),
    "hipsycl_runtime": attr.label(
        doc = """TODO""",
        allow_single_file = True,
        cfg = transition_to_cpp,
    ),
    "hipsycl_omp_backend": attr.label(
        doc = """TODO""",
        # default = ["@hipsycl//:rt-backend-omp"],
        allow_single_file = True,
    ),
    "hipsycl_cuda_backend": attr.label(
        doc = """TODO""",
        # default = ["@hipsycl//:rt-backend-cuda"],
        allow_single_file = True,
    ),
    "hipsycl_hip_backend": attr.label(
        doc = """TODO""",
        # default = ["@hipsycl//:rt-backend-hip"],
    ),
    "hipsycl_hdrs": attr.label_list(
        doc = """TODO""",
    ),
    "leak_sanitizer": attr.label_list(
        doc = "LeakSanitizer libraries.",
        # default = [
        #     "@llvm-project-overlay//compiler-rt/lib/lsan:clang_rt.lsan",
        # ],
    ),
    "linker": attr.label(
        doc = "The linker.",
        allow_single_file = True,
        executable = True,
        cfg = transition_to_bootstrap,
        default = "@llvm-project//lld:lld",
    ),
    "linker_wrapper": attr.label(
        doc = """The clang-linker-wrapper. This invokes the host linker and
        device linkers.""",
        allow_single_file = True,
        executable = True,
        cfg = transition_to_bootstrap,
        default = "@llvm-project//clang:clang-linker-wrapper",
    ),
    "llvm_project_deps": attr.label_list(
        doc = """Targets from the `llvm-project-overlay`. Useful for targets
        that require the `llvm-project`, such as frontend actions, optimization
        passes, Clang plugins etc.
        """,
        cfg = transition_to_bootstrap,
        default = LLVM_PROJECT_DEPS,
    ),
    "local_library_path": attr.label(
        doc = """A symlink to the local library path. This is usually either
        `/usr/lib64` or `/usr/local/x86_64-linux-gnu`.""",
        default = "@local_library_path//:local_library_path",
        allow_single_file = True,
    ),
    "machine_code_tool": attr.label(
        doc = "The llvm-mc tool. Used for separate compilation (CUDA/HIP).",
        cfg = transition_to_bootstrap,
        default = "@llvm-project//llvm:llvm-mc",
        executable = True,
    ),
    "offload_bundler": attr.label(
        doc = """Offload bundler used to bundle code objects for languages
        targeting multiple devices in a single source file, such as GPU code.
        """,
        cfg = transition_to_bootstrap,
        default = "@llvm-project//clang:clang-offload-bundler",
        executable = True,
    ),
    "offload_packager": attr.label(
        doc = """Offload packager used to bundle device files with metadata into
        a single image.""",
        cfg = transition_to_bootstrap,
        default = "@llvm-project//clang:clang-offload-packager",
        executable = True,
    ),
    "memory_sanitizer": attr.label_list(
        doc = """MemorySanitizer libraries.""",
        # default = [
        #     "@llvm-project//compiler-rt/lib/msan:clang_rt.msan",
        #     "@llvm-project//compiler-rt/lib/msan:clang_rt.msan_cxx",
        # ],
    ),
    "symbolizer": attr.label(
        doc = "The llvm-symbolizer.",
        cfg = transition_to_bootstrap,
        default = "@llvm-project//llvm:llvm-symbolizer",
        executable = True,
    ),
    "thread_sanitizer": attr.label_list(
        doc = """ThreadSanitizer libraries.""",
        # default = [
        #     "@llvm-project//compiler-rt/lib/tsan:clang_rt.tsan",
        #     "@llvm-project//compiler-rt/lib/tsan:clang_rt.tsan_cxx",
        # ],
    ),
    "undefined_behavior_sanitizer": attr.label_list(
        doc = """UndefinedBehaviorSanitizer libraries.""",
        # default = [
        #     "@llvm-project//compiler-rt/lib/ubsan:clang_rt.ubsan_standalone",
        #     "@llvm-porject//compiler-rt/lib/ubsan:clang_rt.ubsan_standalone_cxx",
        # ],
    ),
    "unwind_library": attr.label(
        doc = "The unwinder library.",
        cfg = transition_to_bootstrap,
    ),
    "_allowlist_function_transition": attr.label(
        default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
    ),
}

LL_LIBRARY_ATTRS = dicts.add(DEFAULT_ATTRS, LIBRARY_ATTRS)

LL_BINARY_ATTRS = dicts.add(DEFAULT_ATTRS, BINARY_ATTRS)
