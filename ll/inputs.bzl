"""# `//ll:inputs.bzl`

Action inputs for rules.
"""

COMPILABLE_EXTENSIONS = [
    "c",
    "cl",
    "cpp",
    "cu",
    "S",
    "cc",
    "cxx",
    "cpp",
    "pcm",
]

def compilable_sources(ctx):
    return [
        src
        for src in ctx.files.srcs
        if src.extension in COMPILABLE_EXTENSIONS
    ]

#TODO: Documentation lacking.
def compile_object_inputs(
        ctx,
        in_file,
        headers,
        interfaces):
    """Collect all inputs for a compile action.

    Takes files from the arguments and adds files from the `srcs` and `data`
    fields and various toolchain dependencies.

    Args:
        ctx: The rule context.
        in_file: The input file.
        headers: A `depset` of headers.
        interfaces: A `depset` of `(interface, name)` tuples.

    Returns:
        A `depset` of files.
    """
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    return depset(
        [in_file] + (
            ctx.files.data +
            ctx.files.srcs +
            toolchain.builtin_includes +
            toolchain.compiler_runtime +
            toolchain.cpp_abihdrs +
            toolchain.cpp_stdhdrs +
            toolchain.hip_libraries +
            toolchain.hip_runtime +
            toolchain.rocm_device_libs +
            toolchain.unwind_library
        ) + [
            module.bmi
            for module in toolchain.cpp_stdmodules
        ],
        transitive = [
            headers,
            depset([interface.bmi for interface in interfaces.to_list()]),
        ] + (
            [toolchain.llvm_project_sources] if ctx.attr.depends_on_llvm else []
        ),
    )

def create_archive_library_inputs(ctx, in_files):
    return depset(
        [
            file
            for file in in_files + ctx.files.deps
            if file.extension in ["o", "a"]
        ],
    )

def link_executable_inputs(ctx, in_files):
    """Collect all inputs for link actions producing executables.

    Apart from `in_files`, adds files from the `deps`, `libraries` and `data`
    fields and various toolchain dependencies.

    Args:
        ctx: The rule context.
        in_files: A list of files.

    Returns:
        A `depset` of files.
    """
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    return depset(
        in_files +
        ctx.files.data +
        ctx.files.deps +
        ctx.files.libraries +
        toolchain.compiler_runtime +
        toolchain.cpp_abilib +
        toolchain.cpp_stdlib +
        toolchain.hip_libraries +
        toolchain.hip_runtime +
        toolchain.unwind_library +
        (
            toolchain.llvm_project_artifacts if ctx.attr.depends_on_llvm else []
        ) +
        [
            module.bmi
            for module in toolchain.cpp_stdmodules
        ],
    )

def link_shared_object_inputs(ctx, in_files):
    """Collect input files for link actions.

    Adds files from the `deps` and `data` fields and various toolchain
    dependencies.

    Args:
        ctx: The rule context.
        in_files: A list of files.

    Returns:
        A `depset` of files.
    """
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    return depset(
        in_files +
        ctx.files.data +
        ctx.files.deps +
        (
            [ctx.file.version_script] if ctx.file.version_script != None else []
        ) +
        toolchain.compiler_runtime +
        toolchain.cpp_abilib +
        toolchain.cpp_stdlib +
        toolchain.hip_libraries +
        toolchain.unwind_library +
        (
            toolchain.llvm_project_artifacts if ctx.attr.depends_on_llvm else []
        ),
    )
