def compile_object_tools(ctx):
    if "//ll:toolchain_type" in ctx.toolchains:
        return [
            ctx.toolchains["//ll:toolchain_type"].offload_bundler,
            ctx.toolchains["//ll:toolchain_type"].symbolizer,
            ctx.toolchains["//ll:toolchain_type"].bitcode_linker,
            ctx.toolchains["//ll:toolchain_type"].linker,
            ctx.toolchains["//ll:toolchain_type"].linker_executable,
        ]
    elif "//ll:bootstrap_toolchain_type" in ctx.toolchains:
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
