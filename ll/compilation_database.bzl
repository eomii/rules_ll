"""# `//ll:compilation_database.bzl`

Implements the `ll_compilation_database` rule.
"""

load(
    "//ll:providers.bzl",
    "LlCompilationDatabaseFragmentsInfo",
)
load("//ll:outputs.bzl", "ll_artifact")

def _ll_compilation_database(ctx):
    toolchain = ctx.toolchains["//ll:toolchain_type"]

    inputs = []

    for target in ctx.attr.targets:
        inputs += [
            cdf
            for cdf in target[LlCompilationDatabaseFragmentsInfo].cdfs.to_list()
        ]

    # Filter excluded files.
    for exclude in ctx.attr.exclude:
        inputs = [cdf for cdf in inputs if exclude not in cdf.path]

    unmodified_cdb = ctx.actions.declare_file(
        ll_artifact(ctx, "unmodified_compile_commands.json"),
    )

    args = ctx.actions.args()

    # The arguments referenced via ${@:1:$#-1} below.
    args.add_all(inputs)

    # The last argument referenced via ${@:$#} below.
    args.add(unmodified_cdb)

    ctx.actions.run_shell(
        inputs = inputs,
        outputs = [unmodified_cdb],
        # This command appends the first n-1 arguments, prepends with [\n and
        # appends ]\n. The result is then written to the last argument, in our
        # case the output file.
        #
        # $@ is the list of all input arguments.
        # $# is the number of input arguments, i.e. this lenght can be used to
        # index into the last element of $@.
        #
        # ${@:$#} is the last input argument.
        # ${@:1:$#-1} are the input arguments except for the last one.
        #
        # The sed command removes the trailing comma in the second-to-last line
        # so that we get a valid json as output.
        command = """(
         echo [;
         cat ${@:1:$#-1};
         echo ];
      ) | sed 'N; $! { P; D; }; s/,\\n/\\n/' > ${@:$#}
      """,
        arguments = [args],
    )

    # The "directory" fields reference sandbox locations which do not exist
    # after executing compile actions. Hence we change them to reference the
    # workspace location.
    cdb = ctx.actions.declare_file(ll_artifact(ctx, "compile_commands.json"))
    args = ctx.actions.args()

    args.add(unmodified_cdb)
    args.add(cdb)
    ctx.actions.run_shell(
        inputs = [unmodified_cdb],
        outputs = [cdb],
        command = '''python -c """
import os
import sys
import json

with open(sys.argv[1], 'r') as in_file, open(sys.argv[2], 'w') as out_file:
    compilation_database = json.load(in_file)

    revised_compilation_database = [
        fragment
        for fragment in compilation_database
        if not fragment['file'].endswith('.pcm')
    ]

    for fragment in revised_compilation_database:
        fragment['directory'] = '$(pwd)'

        # Workaround for https://github.com/llvm/llvm-project/issues/59291.
        for arg in fragment['arguments']:
            if arg == '-xcuda':
                fragment['arguments'] += ['--offload-host-only']
            if arg.startswith('--offload-arch'):
                fragment['arguments'].remove(arg)
            if arg == '--cuda-noopt-device-debug':
                fragment['arguments'].remove(arg)

    json.dump(revised_compilation_database, out_file)
""" $1 $2
''',
        execution_requirements = {
            "no-remote": "1",
            "no-sandbox": "1",
        },
        arguments = [args],
    )

    clang_tidy_runner = ctx.actions.declare_file(
        ll_artifact(ctx, "run_clang_tidy.sh"),
    )

    runfile_content = """#!/bin/bash
echo "Running clang-tidy. This may take a while.";
{runner} -j $(nproc) -quiet -use-color -clang-tidy-binary={binary} -config-file={config};
""".format(
        runner = toolchain.clang_tidy_runner.short_path,
        binary = toolchain.clang_tidy.short_path,
        config = ctx.file.config.short_path,
    )
    ctx.actions.write(clang_tidy_runner, runfile_content, is_executable = True)

    runfiles = ctx.runfiles(
        files = [
            cdb,
            toolchain.clang_tidy_runner,
            toolchain.clang_tidy,
            ctx.file.config,
        ],
    )
    return [
        DefaultInfo(
            files = depset([cdb]),
            executable = clang_tidy_runner,
            runfiles = runfiles,
        ),
    ]

ll_compilation_database = rule(
    implementation = _ll_compilation_database,
    executable = True,
    attrs = {
        "config": attr.label(
            doc = "The label of a `.clang-tidy` configuration file.",
            allow_single_file = True,
            mandatory = True,
        ),
        "exclude": attr.string_list(
            doc = """
            Exclude all targets whose path includes one at least one of the
            provided strings.
            """,
            default = [],
        ),
        "targets": attr.label_list(
            mandatory = True,
            doc = "The labels added to the compilation database.",
        ),
    },
    toolchains = ["//ll:toolchain_type"],
    doc = """
Executable target for building a
[compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
and running [clang-tidy](https://clang.llvm.org/extra/clang-tidy/) on it.

For a full guide see [Clang-Tidy](../guides/clang_tidy.md).

See [`rules_ll/examples`](https://github.com/eomii/rules_ll/tree/main/examples) for examples.
""",
)
