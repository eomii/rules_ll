def _get_dirname(file):
    return file.dirname

def construct_default_args(ctx, headers, includes, defines):
    args = ctx.actions.args()

    # Always print diagnostics in color.
    args.add("-v")
    args.add("-fcolor-diagnostics")

    # Disable the default gcc toolchain.
    args.add("--gcc-toolchain=MASKED")

    # Disable any leftover default libraries.
    args.add("-nodefaultlibs")

    # Headers.
    args.add_all(headers, before_each = "-I", map_each = _get_dirname, uniquify = True)

    # Includes.
    args.add_all(includes, before_each = "-I", uniquify = True)

    # Defines.
    args.add_all(defines, before_each = "-D")

    return args
