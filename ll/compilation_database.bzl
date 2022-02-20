"""# `//ll:compilation_database.bzl`

Implements the `ll_compilation_database` rule.
"""

load(
    "//ll:providers.bzl",
    "LlCompilationDatabaseFragmentsInfo",
    "LlCompilationDatabaseInfo",
)

def _ll_compilation_database(ctx):
    inputs = ctx.attr.target[LlCompilationDatabaseFragmentsInfo].cdfs

    unmodified_cdb = ctx.actions.declare_file(
        "unmodified_compile_commands.json",
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

    # The "directory" fields reference sandbox locations which do not exist after
    # executing compile actions. Hence we change them to reference the workspace
    # location.
    cdb = ctx.actions.declare_file("compile_commands.json")
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

    for fragment in compilation_database:
        print(fragment['directory'])
        fragment['directory'] = '$(pwd)'
    json.dump(compilation_database, out_file)
""" $1 $2
''',
        execution_requirements = {
            "no-sandbox": "1",
            "no-cache": "1",
            "no-remote": "1",
            "local": "1",
        },
        arguments = [args],
    )

    clang_tidy_runner = ctx.actions.declare_file("run_clang_tidy.sh")
    runfile_content = """#!/bin/bash
    echo "Running clang-tidy. This may take a while.";
{} -j $(nproc) -clang-tidy-binary={} -quiet""".format(
        ctx.toolchains["//ll:toolchain_type"].clang_tidy_runner.path,
        ctx.toolchains["//ll:toolchain_type"].clang_tidy.short_path,
        ctx.file.config.path,
    )
    ctx.actions.write(clang_tidy_runner, runfile_content, is_executable = True)

    runfiles = ctx.runfiles(
        files = [
            cdb,
            ctx.toolchains["//ll:toolchain_type"].clang_tidy_runner,
            ctx.toolchains["//ll:toolchain_type"].clang_tidy,
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
        "target": attr.label(
            mandatory = True,
            doc = """
            The label for which the compilation database should be built.
            """,
        ),
        "config": attr.label(
            doc = """
            The label of a `.clang-tidy` configuration file.

            This file should be at the root of your project directory.
            """,
            allow_single_file = True,
        ),
    },
    toolchains = ["//ll:toolchain_type"],
    doc = """
Executable target for building a
[compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
and running [clang-tidy](https://clang.llvm.org/extra/clang-tidy/) on it.

For a full guide see
[Using `rules_ll` with `clang-tidy`](https://qogecoin.github.io/rules_ll/guides/clang_tidy.html).

An example project using this rule is available at
[rules_ll/examples](https://github.com/qogecoin/rules_ll/tree/main/examples).
""",
)
