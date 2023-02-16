"""# `//ll:outputs.bzl`

Action outputs.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")

def ll_artifact(ctx, filename = None):
    """Return a string of the form `"{ctx.label.name}/filename"`.

    Encapsulate intermediary build artifacts to avoid name clashes for files of
    the same name built by targets in the same build invocation.

    Args:
        ctx: The build context.
        filename: An optional string representing a filename. If omitted,
            creates a path of the form `"{ctx.label.name}"`.
    """
    if filename == None:
        return "{}".format(ctx.label.name)

    return "{}/{}".format(ctx.label.name, filename)

def link_executable_outputs(ctx):
    """For a label `filename` return a file of the same name."""
    return ctx.actions.declare_file(ll_artifact(ctx, ctx.label.name))

def link_bitcode_library_outputs(ctx):
    """For a label `filename` return a file `filename.bc`."""
    return ctx.actions.declare_file(ll_artifact(ctx, ctx.label.name + ".bc"))

def link_shared_object_outputs(ctx):
    """For a label `filename` return a file `filename.so`."""
    return ctx.actions.declare_file(ll_artifact(ctx, ctx.label.name + ".so"))

def create_archive_library_outputs(ctx):
    """For a label `filename` return a file `filename.a`."""
    return ctx.actions.declare_file(ll_artifact(ctx, ctx.label.name + ".a"))

def precompile_interface_outputs(ctx, in_file):
    """Given a file `f.cppm` return files `f.pcm` and `f.pcm.cdf`.

    Args:
        ctx: The rule context.
        in_file: A `file`.

    Returns:
        A tuple `(out_file, cdf)`.
    """
    build_file_path = paths.join(
        ctx.label.workspace_root,
        paths.dirname(ctx.build_file_path),
    )

    relative_src_path = paths.relativize(in_file.path, build_file_path)
    relative_src_dir = paths.dirname(relative_src_path)

    out_file = ctx.actions.declare_file(
        paths.join(
            relative_src_dir,
            paths.replace_extension(ll_artifact(ctx, in_file.basename), ".pcm"),
        ),
    )

    cdf = ctx.actions.declare_file(
        paths.join(
            relative_src_dir,
            paths.replace_extension(ll_artifact(ctx, in_file.basename), ".pcm.cdf"),
        ),
    )

    return out_file, cdf

def compile_object_outputs(ctx, in_file):
    """Given a compilable file, return an output name for the compiled object.

    Args:
        ctx: The rule context.
        in_file: A `file`.

    Returns:
        A tuple `(out_file, cdf)`. Outputs end with `.o`/`.cdf` or
        `.interface.o`/`.interface.cdf`, if `in_file` has a `.pcm` extension.
    """

    # TODO: Why did we add these paths?
    build_file_path = paths.join(
        ctx.label.workspace_root,
        paths.dirname(ctx.build_file_path),
    )
    if in_file.extension == "pcm":
        relative_src_path = paths.relativize(
            in_file.path,
            paths.join(in_file.root.path, build_file_path),
        )
        extension = ".interface.o"
        cdf_extension = ".interface.cdf"
    else:
        relative_src_path = paths.relativize(in_file.path, build_file_path)
        extension = ".o"
        cdf_extension = ".cdf"

    relative_src_dir = paths.dirname(relative_src_path)

    out_file = ctx.actions.declare_file(
        paths.join(
            relative_src_dir,
            paths.replace_extension(ll_artifact(ctx, in_file.basename), extension),
        ),
    )

    cdf = ctx.actions.declare_file(
        paths.join(
            relative_src_dir,
            paths.replace_extension(ll_artifact(ctx, in_file.basename), cdf_extension),
        ),
    )
    return out_file, cdf
