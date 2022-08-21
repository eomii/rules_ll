"""# `//ll:outputs.bzl`

Action outputs.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")

def link_executable_outputs(ctx):
    return ctx.actions.declare_file(ctx.label.name)

def link_bitcode_library_outputs(ctx):
    return ctx.actions.declare_file(ctx.label.name + ".bc")

def link_shared_object_outputs(ctx):
    return ctx.actions.declare_file(ctx.label.name + ".so")

def create_archive_library_outputs(ctx):
    return ctx.actions.declare_file(ctx.label.name + ".a")

def precompile_module_outputs(ctx, in_file):
    build_file_path = paths.join(
        ctx.label.workspace_root,
        paths.dirname(ctx.build_file_path),
    )
    relative_src_path = paths.relativize(in_file.path, build_file_path)
    relative_src_dir = paths.dirname(relative_src_path)

    return ctx.actions.declare_file(
        paths.join(
            relative_src_dir,
            paths.replace_extension(in_file.basename, ".pcm"),
        ),
    )

def compile_object_outputs(ctx, in_file):
    # TODO: Why did we add these paths?
    build_file_path = paths.join(
        ctx.label.workspace_root,
        paths.dirname(ctx.build_file_path),
    )
    if in_file.extension == "pcm":
        relative_src_path = paths.relativize(in_file.short_path, build_file_path)
    else:
        relative_src_path = paths.relativize(in_file.path, build_file_path)
    relative_src_dir = paths.dirname(relative_src_path)

    out_file = ctx.actions.declare_file(
        paths.join(
            relative_src_dir,
            paths.replace_extension(in_file.basename, ".o"),
        ),
    )

    cdf = ctx.actions.declare_file(
        paths.join(
            relative_src_dir,
            paths.replace_extension(in_file.basename, ".cdf"),
        ),
    )
    return out_file, cdf
