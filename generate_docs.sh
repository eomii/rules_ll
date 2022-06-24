#/bin/sh

# Build docs_source.
bazel build --noexperimental_enable_bzlmod //ll:docs
chmod 644 bazel-bin/ll/*.md
cp bazel-bin/ll/*.md docs_source

# Rebuild the Sphinx documentation.
rm -rd docs
sphinx-build -b html docs_source docs

# Rerun the pre-commit hooks so that we do not need to stage everything twice.
git add docs
pre-commit run --all-files
git add docs

# Technically unnecessary, but we want to show users whether all tests pass.
echo ""
echo "**************************"
echo "RERUNNING PRE-COMMIT HOOKS"
echo "**************************"
echo ""
pre-commit run --all-files
