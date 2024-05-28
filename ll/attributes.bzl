"""# `//ll:attributes.bzl`

Attributes used by the `ll_toolchain`, `ll_library` and `ll_binary` rules.
"""

load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("//ll:llvm_project_deps.bzl", "LLVM_PROJECT_DEPS")
load("//ll:providers.bzl", "LlInfo")
load(
    "//ll:transitions.bzl",
    "transition_to_bootstrap",
    "transition_to_cpp",
)

DEFAULT_ATTRS = {
    "compilation_mode": attr.string(
        doc = """Enables compilation of heterogeneous single source files.

        Prefer this attribute over adding SYCL/HIP/CUDA flags manually in the
        `compile_flags` and `link_flags`.

        See [CUDA and HIP](../guides/cuda_and_hip.md).

        `"cpp"` The default C++ toolchain.

        `"cuda_nvptx"` The CUDA toolchain.

        `"hip_nvptx"` The HIP toolchain.

        `"bootstrap"` The bootstrap toolchain used by internal dependencies of
        the `ll_toolchain`.
        """,
        default = "cpp",
        # TODO: hip_amd, sycl_amd
        values = [
            "cpp",
            "cuda_nvptx",
            "hip_amdgpu",
            "hip_nvptx",
            "bootstrap",
        ],
    ),
    "compile_flags": attr.string_list(
        doc = """Flags for the compiler.

        Pass a list of strings here. For instance `["-O3", "-std=c++20"]`.

        Split flag pairs `-Xclang -somearg` into separate flags
        `["-Xclang", "-somearg"]`.

        Unavailable to downstream targets.
        """,
    ),
    "compile_string_flags": attr.label_list(
        doc = """Flags for the compiler in the form of `string_flag`s.

        Splits the values of each `string_flag` along colons like so:

        ```python
        load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

        string_flag(
            name = "myflags",
            build_setting_default = "a:b:c",
        )

        ll_library(
            # ...
            # Equivalent to `compile_flags = ["a", "b", "c"]`
            compile_string_flags = [":myflags"],
        )
        ```

        Useful for externally configurable build attributes, such as generated
        flags from Nix environments.
        """,
    ),
    "experimental_device_intrinsics": attr.label_list(
        doc = """Custom intrinsics for device compilation.

        Adds `-Xarch_device -include<thefile>` to the compile commands for this
        target.
        """,
        allow_files = True,
    ),
    "depends_on_llvm": attr.bool(
        doc = """Whether this target directly depends on targets from the
        `llvm-project-overlay`.

        Setting this to `True` makes the `cc_library` targets from the LLVM
        project overlay available to this target.
        """,
        default = False,
    ),
    "data": attr.label_list(
        doc = """Extra files made available to compilation and linking steps.

        Not appended to the default command line arguments, but available to
        actions. Reference these files manually for instance in the `includes`,
        and `compile_flags` attributes.

        Use this attribute to make intermediary outputs from non-ll targets, for
        example from `rules_cc` or `filegroup`, available to the rule.
        """,
        allow_files = True,
    ),
    "defines": attr.string_list(
        doc = """Defines for this target.

        Pass a list of strings here. For instance
        `["MYDEFINE_1", "MYDEFINE_2"]`.

        Unavailable to downstream targets.
        """,
    ),
    "deps": attr.label_list(
        doc = """The dependencies for this target.

        Use `ll_library` targets here. Other targets won't work.
        """,
        providers = [LlInfo],
    ),
    "exposed_defines": attr.string_list(
        doc = """Exposed defines for this target.

        Added to the compile command line arguments of direct dependents.
        """,
    ),
    "exposed_hdrs": attr.label_list(
        doc = """Exposed headers for this target.

        Direct dependents can see exposed headers. Put the public API headers
        for libraries here.
        """,
        allow_files = True,
    ),
    "exposed_interfaces": attr.label_keyed_string_dict(
        doc = """Transitive interfaces for this target.

        See [C++ modules](../guides/modules.md) for a guide.

        Makes precompiled modules and compiled objects visible to direct
        dependents. Files in this attribute can see BMIs from modules in
        `interfaces`.

        Primary module interfaces go here.
        """,
        allow_files = [".cppm", ".cpp", ".cc"],
    ),
    "exposed_angled_includes": attr.string_list(
        doc = """Exposed angled include paths, relative to the original target
        workspace.

        Expands paths starting with `$(GENERATED)` to the workspace location in
        the `GENDIR` path.

        Added to the compile command line arguments of direct dependents.
        """,
    ),
    "exposed_includes": attr.string_list(
        doc = """Exposed include paths, relative to the original target
        workspace.

        Expands paths starting with `$(GENERATED)` to the workspace location in
        the `GENDIR` path.

        Added to the compile command line arguments of direct dependents.
        """,
    ),
    "hdrs": attr.label_list(
        doc = """Header files for this target.

        When including a header file with a nested path, for instance
        `#include "some/path/myheader.h"`, add `"some/path"` to `includes`
        to make it visible to the rule.

        Unavailable to downstream targets.
        """,
        allow_files = True,
    ),
    "interfaces": attr.label_keyed_string_dict(
        doc = """Module interfaces for this target.

        See [C++ modules](../guides/modules.md) for a guide.

        Makes precompiled modules and compiled objects visible to direct
        dependents and to `exposed_interfaces`.

        For instance, you can put module partitions in `interfaces` and the
        primary module interface in `exposed_interfaces`.

        Files in the same `interfaces` attribute can't see each other's BMIs.
        """,
        allow_files = [".cppm"],
    ),
    "angled_includes": attr.string_list(
        doc = """Angled include paths, relative to the target workspace.

        Useful if you require include prefix stripping for dynamic paths, for
        instance the ones generated by `bzlmod`. Instead of
        `compile_flags = ["-Iexternal/mydep.someversion/include"]`, use
        `angled_includes = ["include"]` to add the path to the workspace
        automatically.

        Expands paths starting with `$(GENERATED)` to the workspace location in
        the `GENDIR` path.

        Unavailable to downstream targets.
        """,
    ),
    "includes": attr.string_list(
        doc = """Include paths, relative to the target workspace.

        Uses `-iquote`.

        Useful if you need custom include prefix stripping for dynamic paths,
        for instance the ones generated by `bzlmod`. Instead of
        `compile_flags = ["-iquoteexternal/mydep.someversion/include"]`, use
        `includes = ["include"]` to add the path to the workspace
        automatically.

        Expands paths starting with `$(GENERATED)` to the workspace location in
        the `GENDIR` path.

        Unavailable to downstream targets.
        """,
    ),
    "sanitize": attr.string_list(
        doc = """Enable sanitizers for this target.

        See the [Sanitizers](../guides/sanitizers.md) guide.

        Some sanitizers come with heavy performance penalties. Enabling several
        sanitizers at the same time often breaks builds. If possible, use just
        one at a time.

        Sanitizers produce nondeterministic error reports. Run sanitized
        executables several times and build them with different optimization
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

        Allowed file extensions: `[".ll", ".o", ".S", ".c", ".cl", ".cpp"]`.

        Place headers in the `hdrs` attribute.
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
    "emit": attr.string_list(
        doc = """Sets the output mode.

        You can enable several output types at the same time.

        `"archive"` invokes the archiver and adds an archive with a `.a`
        extension to the outputs.

        `"shared_object"` invokes the linker and adds a shared object with a
        `.so` extension to the outputs.

        `"objects"` adds loose object files to the outputs.
        """,
        default = ["archive"],
    ),
    "shared_object_link_flags": attr.string_list(
        doc = """Flags for the linker when emitting shared objects.

        Used if `emit` includes `"shared_object"`.
        """,
    ),
    "shared_object_link_string_flags": attr.label_list(
        doc = """Flags for the linker when emitting shared objects in the form
        of `string_flag`s.

        See `compile_string_flags` for semantics.

        Used if `emit` includes `"shared_object"`.
        """,
    ),
}

BINARY_ATTRS = {
    "libraries": attr.label_list(
        doc = """Libraries linked to the final executable.

        Adds these libraries to the command line arguments for the linker.
        """,
        allow_files = True,
    ),
    "link_flags": attr.string_list(
        doc = """Flags for the linker.

        Place library search paths and external link targets here.

        Assuming you have a library `/some/path/libmylib.a` on your host system,
        you can make `mylib.a` available to the linker by passing
        `["-L/some/path", "-lmylib"]` to this attribute.

        Prefer the `libraries` attribute for library files already present
        within the Bazel build graph.
        """,
    ),
    "link_string_flags": attr.label_list(
        doc = """Flags for the linker in the form of `string_flag`s.

        See `compile_string_flags` for semantics.

        Prefer the `libraries` attribute for library files already present
        within the Bazel build graph.
        """,
    ),
}

LL_TOOLCHAIN_ATTRS = {
    "address_sanitizer": attr.label_list(
        doc = "AddressSanitizer libraries.",
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
        doc = "The linker for LLVM bitcode files.",
        executable = True,
        cfg = transition_to_bootstrap,
        default = "@llvm-project//llvm:llvm-link",
    ),
    "builtin_includes": attr.label(
        doc = "Clang's built-in header files.",
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
        doc = "The clang-tidy binary.",
        cfg = transition_to_bootstrap,
        default = "@llvm-project//clang-tools-extra/clang-tidy:clang-tidy",
        executable = True,
    ),
    "clang_tidy_runner": attr.label(
        doc = "The `run-clang-tidy.py` wrapper script for clang-tidy.",
        cfg = transition_to_bootstrap,
        default = "@llvm-project//clang-tools-extra/clang-tidy:run-clang-tidy",
        executable = True,
    ),
    "compiler_runtime": attr.label_list(
        doc = "The compiler runtime.",
        cfg = transition_to_bootstrap,
        providers = [LlInfo],
    ),
    "cov": attr.label(
        doc = "The `llvm-cov` tool.",
        cfg = transition_to_bootstrap,
        default = "@llvm-project//llvm:llvm-cov",
        executable = True,
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
        allow_files = True,
        # Don't transition for now. It breaks the generated config.
    ),
    "cpp_stdlib": attr.label(
        doc = "The C++ standard library.",
        cfg = transition_to_bootstrap,
        providers = [LlInfo],
    ),
    "opt": attr.label(
        doc = "The LLVM `opt` tool.",
        cfg = transition_to_bootstrap,
        allow_single_file = True,
        executable = True,
        default = "@llvm-project//llvm:opt",
    ),
    "objcopy": attr.label(
        doc = "The `llvm-objcopy` tool.",
        cfg = transition_to_bootstrap,
        allow_single_file = True,
        executable = True,
        default = "@llvm-project//llvm:llvm-objcopy",
    ),
    "hip_libraries": attr.label_list(
        doc = """The HIP libraries.

        `rules_ll` still uses `clang` to compile device code.

        Using this implies acceptance of the AMD's license for HIP.

        Using HIP to target Nvidia devices implies use of the Nvidia CUDA
        toolkit.
        """,
        # default = [
        #     "@hip//:headers",
        #     "@hipamd//:headers",
        # ],
        cfg = transition_to_cpp,
    ),
    "hip_runtime": attr.label_list(
        doc = "The libamdhip64 runtime.",
        # default = "@hipamd//:libamdhip64",
        cfg = transition_to_cpp,
    ),
    "leak_sanitizer": attr.label_list(
        doc = "LeakSanitizer libraries.",
        # default = [
        #     "@llvm-project-overlay//compiler-rt/lib/lsan:clang_rt.lsan",
        # ],
    ),
    "linker": attr.label(
        doc = """The linker.

        Called by the `clang-linker-wrapper`.
        """,
        allow_single_file = True,
        executable = True,
        cfg = transition_to_bootstrap,
        default = "@llvm-project//lld:lld",
    ),
    "linker_wrapper": attr.label(
        doc = """The `clang-linker-wrapper`.

        This wraps the host linker and the device linkers.""",
        allow_single_file = True,
        executable = True,
        cfg = transition_to_bootstrap,
        default = "@llvm-project//clang:clang-linker-wrapper",
    ),
    "llvm_project_deps": attr.label_list(
        doc = """Targets from the `llvm-project-overlay`.

        Useful for targets that depend on the `llvm-project`. For instance
        frontend actions and Clang plugins.
        """,
        cfg = transition_to_bootstrap,
        default = LLVM_PROJECT_DEPS,
    ),
    "machine_code_tool": attr.label(
        doc = """The `llvm-mc` tool.

        Used when building CUDA and HIP with `-fgpu-rdc`..
        """,
        cfg = transition_to_bootstrap,
        default = "@llvm-project//llvm:llvm-mc",
        executable = True,
    ),
    "offload_bundler": attr.label(
        doc = """The `clang-offload-bundler`.

        Bundles the device code objects for GPU code.
        """,
        cfg = transition_to_bootstrap,
        default = "@llvm-project//clang:clang-offload-bundler",
        executable = True,
    ),
    "offload_packager": attr.label(
        doc = """The `clang-offload-packager`.
        """,
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
    "profdata": attr.label(
        doc = "The `llvm-profdata` tool.",
        cfg = transition_to_bootstrap,
        default = "@llvm-project//llvm:llvm-profdata",
        executable = True,
    ),
    "profile": attr.label(
        doc = "The clang_rt.profile implementation",
        # default = "@llvm-project//compiler-rt/lib/profile:clang_rt.profile",
    ),
    "rocm_device_libs": attr.label(
        doc = "The ROCm-Device-Libs.",
        # default "@rocm-device-libs//:rocm-device-libs",
        cfg = transition_to_cpp,
    ),
    "symbolizer": attr.label(
        doc = "The `llvm-symbolizer`.",
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
    # These values are intended to be set via string_flags. For instance,
    # `ll_cflags` should be set to `@rules_ll//ll:LL_CFLAGS`. This is done in
    # the ll_toolchain instantiation in `ll/BUILD.bazel`.
    "LL_CFLAGS": attr.label(
        doc = "Arbitrary flags added to all compile actions.",
    ),
    "LL_LDFLAGS": attr.label(
        doc = "Arbitrary flags added to all link actions.",
    ),
    "LL_DYNAMIC_LINKER": attr.label(
        doc = "The linker from the glibc we compile and link against.",
    ),
    "LL_AMD_INCLUDES": attr.label(
        doc = """System includes for dependencies making use of AMD toolchains.

        Affects the `hip_amdgpu` and `hip_nvptx` toolchains.
        """,
    ),
    "LL_AMD_LIBRARIES": attr.label(
        doc = """Link search paths for dependencies making use of AMD toolchains.

        Affects the `hip_amdgpu` toolchain.
        """,
    ),
    "LL_CUDA_TOOLKIT": attr.label(
        doc = """The path to the CUDA toolkit.

        Affects the `cuda_nvptx` and `hip_nvptx` toolchains.
        """,
    ),
    "LL_CUDA_DRIVER": attr.label(
        doc = """The path to the CUDA driver.

        Affects the `cuda_nvptx` and `hip_nvptx` toolchains.
        """,
    ),
}

LL_LIBRARY_ATTRS = dicts.add(DEFAULT_ATTRS, LIBRARY_ATTRS)

LL_BINARY_ATTRS = dicts.add(DEFAULT_ATTRS, BINARY_ATTRS)
