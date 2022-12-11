"""# `//ll:outputs.bzl`

Action outputs.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")

def ll_artifact(ctx, filename = None):
    """Returns a string like "<ctx.label.name>/filename"

    We use this method to encapsulate intermediary build artifacts so that we
    don't get name clashes for files of the same name built by targets in the
    same build invocation.

    Args:
        ctx: The build context.
        filename: An optional string representing a filename. If omitted, only
            creates a path like "<ctx.label.name>".
    """
    if filename == None:
        return "{}".format(ctx.label.name)

    return "{}/{}".format(ctx.label.name, filename)

def link_executable_outputs(ctx):
    return ctx.actions.declare_file(ll_artifact(ctx, ctx.label.name))

def link_bitcode_library_outputs(ctx):
    return ctx.actions.declare_file(ll_artifact(ctx, ctx.label.name + ".bc"))

def link_shared_object_outputs(ctx):
    return ctx.actions.declare_file(ll_artifact(ctx, ctx.label.name + ".so"))

def create_archive_library_outputs(ctx):
    return ctx.actions.declare_file(ll_artifact(ctx, ctx.label.name + ".a"))

def precompile_interface_outputs(ctx, in_file):
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
