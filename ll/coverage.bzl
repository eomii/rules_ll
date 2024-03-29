"""# `//ll:coverage.bzl`

Implements the `ll_coverage_test` rule.
"""

load("//ll:outputs.bzl", "ll_artifact")

def _ll_coverage_impl(ctx):
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    # Generate the raw profile data.
    profraw = ctx.actions.declare_file(
        ll_artifact(ctx, ctx.executable.target.basename + ".profraw"),
    )

    ctx.actions.run(
        outputs = [profraw],
        executable = ctx.executable.target,
        env = {"LLVM_PROFILE_FILE": profraw.path},
    )

    # Merge the raw profile data to profile data.
    profdata = ctx.actions.declare_file(
        ll_artifact(ctx, ctx.executable.target.basename + ".profdata"),
    )

    args = ctx.actions.args()
    args.add_all([
        "merge",
        "-sparse",
        profraw,
        "-o",
        profdata,
    ])

    ctx.actions.run(
        inputs = [profraw],
        outputs = [profdata],
        executable = toolchain.profdata,
        arguments = [args],
    )

    # Generate a website for visualization. This is only useful when this rule
    # was run via "bazel coverage", as coverage details require instrumented
    # builds.
    maybe_html = []
    if ctx.configuration.coverage_enabled:
        html = ctx.actions.declare_file(
            ll_artifact(ctx, ctx.attr.name + ".html"),
        )

        args = ctx.actions.args()
        args.add_all([
            "show",
            ctx.executable.target,
            "-instr-profile",
            profdata,
            "-format=html",
            "-show-branches=count",
            "-show-expansions",
            "-show-line-counts-or-regions",
            "-o",
            html,
        ])

        ctx.actions.run(
            inputs = [profdata, ctx.executable.target],
            tools = ctx.attr.target[InstrumentedFilesInfo].instrumented_files,
            outputs = [html],
            executable = toolchain.cov,
            arguments = [args],
        )
        maybe_html = [html]

    # This runner displays the coverage report summary when running via
    # "bazel run" or "bazel test --test_output=all".
    coverage_runner = ctx.actions.declare_file(
        ll_artifact(ctx, ctx.attr.name + ".sh"),
    )
    runfile_content = """#!/bin/bash
{cov} report {executable} -instr-profile={profdata}
""".format(
        cov = toolchain.cov.short_path,
        executable = ctx.executable.target.short_path,
        profdata = profdata.short_path,
    )
    ctx.actions.write(coverage_runner, runfile_content, is_executable = True)

    runfiles = ctx.runfiles(
        files = [
            profdata,
            toolchain.cov,
            ctx.executable.target,
        ],
        transitive_files = ctx.attr.target[InstrumentedFilesInfo].instrumented_files,
    )

    out_files = depset([profraw, profdata] + maybe_html)

    return DefaultInfo(
        files = out_files,
        executable = coverage_runner,
        runfiles = runfiles,
    )

ll_coverage_test = rule(
    implementation = _ll_coverage_impl,
    doc = "TODO",
    executable = True,
    attrs = {
        "target": attr.label(
            doc = "The executable to run and collect coverage data from.",
            mandatory = True,
            executable = True,
            cfg = "target",
        ),
    },
    toolchains = ["//ll:toolchain_type"],
    test = True,
)
