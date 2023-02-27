# Contributing

`rules_ll` uses code-quality tools for a consistent style across the repository.

## Pre-commit hooks

Use the `rules_ll` development shell to get the various tools you need to work
on the project:

```bash
nix develop github:eomii/rules_ll#dev
```

From within the `rules_ll` development shell, setup vale and the pre-commit
hooks and verify that all checks pass:

```bash title="(from within the rules_ll root directory)"
vale sync
pre-commit install
pre-commit run --all-files
```

After this, they run automatically on every local commit.

## Building the docs

`rules_ll` uses `mkdocs` for the docs. To run a local development server:

```bash title="(from within the rules_ll root directory)"
mkdocs serve
```

If you change documentation in the `ll/` directory, regenerate the API reference
docs:

```bash title="(from within the rules_ll root directory)"
./generate_docs.sh
```

This populates the `docs/reference/` directory with the updated markdown files.

## Tests

The examples at `rules_ll/examples` also act as tests for the project. To test
all examples:

```bash title="(from within the rules_ll/examples directory)"
bazel test //:examples
```

Since not everyone has a GPU compatible with `rules_ll`, heterogeneous examples
don't run by default. Make sure to enable them in `examples/BUILD.bazel`
when changing logic affecting heterogeneous code paths.
