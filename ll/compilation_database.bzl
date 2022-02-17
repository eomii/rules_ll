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

    clang_tidy_runner = ctx.actions.declare_file("hello.sh")
    runfile_content = """#!/bin/bash
    ls external/llvm-project/clang-tools-extra/clang-tidy/clang-tidy;
{} -j $(nproc) -clang-tidy-binary={} -checks=* -quiet""".format(
        ctx.toolchains["//ll:toolchain_type"].clang_tidy_runner.path,
        ctx.toolchains["//ll:toolchain_type"].clang_tidy.short_path,
    )
    ctx.actions.write(clang_tidy_runner, runfile_content, is_executable = True)

    runfiles = ctx.runfiles(
        files = [
            cdb,
            ctx.toolchains["//ll:toolchain_type"].clang_tidy_runner,
            ctx.toolchains["//ll:toolchain_type"].clang_tidy,
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
        "target": attr.label(mandatory = True),
    },
    toolchains = ["//ll:toolchain_type"],
)
