"""# `//ll:tools.bzl`

Tools used by actions.
"""

def compile_object_tools(ctx, toolchain_type):
    if toolchain_type == "//ll:toolchain_type":
        return [
            ctx.toolchains[toolchain_type].symbolizer,
            ctx.toolchains[toolchain_type].bitcode_linker,
            ctx.toolchains[toolchain_type].linker,
            ctx.toolchains[toolchain_type].linker_executable,
        ]
    elif toolchain_type == "//ll:heterogeneous_toolchain_type":
        return [
            ctx.toolchains[toolchain_type].offload_bundler,
            ctx.toolchains[toolchain_type].symbolizer,
            ctx.toolchains[toolchain_type].bitcode_linker,
            ctx.toolchains[toolchain_type].linker,
            ctx.toolchains[toolchain_type].linker_executable,
        ]
    elif toolchain_type == "//ll:bootstrap_toolchain_type":
        return []
    else:
        fail("Unregognized toolchain type. rules_ll supports " +
             "//ll:toolchain_type and //ll:bootstrap_toolchain_type.")

def linking_tools(ctx):
    if "//ll:toolchain_type" in ctx.attr.toolchains:
        return [
            ctx.toolchains["//ll:toolchain_type"].linker,
        ]
    else:
        fail("Can only link when using \"//ll:toolchain_type\".")
