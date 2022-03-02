"""# `//ll:outputs.bzl`

Action outputs.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")

def link_executable_outputs(ctx):
    return ctx.actions.declare_file(ctx.label.name)

def link_bitcode_library_outputs(ctx):
    return ctx.actions.declare_file(ctx.label.name + ".bc")

def create_archive_library_outputs(ctx):
    return ctx.actions.declare_file(ctx.label.name + ".a")

def compile_object_outputs(ctx, in_file):
    build_file_path = paths.join(
        ctx.label.workspace_root,
        paths.dirname(ctx.build_file_path),
    )
    relative_src_path = paths.relativize(in_file.path, build_file_path)
    relative_src_dir = paths.dirname(relative_src_path)

    if "-emit-llvm" in ctx.attr.compile_flags:
        out_file = ctx.actions.declare_file(
            paths.join(
                relative_src_dir,
                paths.replace_extension(in_file.basename, ".bc"),
            ),
        )
    else:
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
