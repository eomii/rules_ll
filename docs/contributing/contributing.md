# Contributing

`rules_ll` uses code-quality tools for a consistent style across the repository.

## Pre-commit hooks

From within a `rules_ll` shell, install the pre-commit hooks and verify that all
checks pass:

```bash
pre-commit install
pre-commit run --all-files
```

After this, they run automatically on every local commit.

## Building the docs

`rules_ll` uses `mkdocs` for the docs. To run a local development server:

```bash
mkdocs serve
```

If you change documentation in the `ll/` directory, regenerate the API reference
docs:

```bash
./generate_docs.sh
```

This populates the `docs/reference/` directory with the updated markdown files.

The text quality linter Vale has no pre-commit integration at the moment. Sync
Vale manually once to get the right packages:

```bash
vale sync
```

Then you can use it on the docs directory to find text inconsistencies:

```bash
vale docs
```
