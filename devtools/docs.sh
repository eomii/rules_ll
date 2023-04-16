#!/bin/bash

# Build docs_source.
bazel build --config=docs //ll:docs || exit
chmod 644 bazel-bin/ll/*.md
cp bazel-bin/ll/*.md docs/reference
cp bazel-bin/ll/defs.md docs/rules

# Rerun the pre-commit hooks so that we do not need to stage everything twice.
git add docs
pre-commit run --all-files
git add docs

# Technically unnecessary, but we want to show users whether all tests pass.
printf '
**************************
RERUNNING PRE-COMMIT HOOKS
**************************
'
pre-commit run --all-files
