# Contributing

`rules_ll` uses code-quality tools for a consistent style across the repository.

## Pre-commit hooks

Install the pre-commit hooks and verify that all checks pass:

```bash
pip install -r requirements.txt
pre-commit install
pre-commit run --all-files
```

After this, they run automatically on every local commit.

## Building the docs

`rules_ll` uses `mkdocs` for the docs. To run a local development server:

```bash
mkdocs serve
```

If you change anything in the `ll/` directory, regenerate the API reference docs:

```bash
./generate_docs.sh
```

This populates the `docs/reference/` directory with the updated markdown files.

The text quality linter Vale has no pre-commit integration at the moment. You
can run these commands to set it up instead:

```bash
wget https://github.com/errata-ai/vale/releases/download/v2.21.3/vale_2.21.3_Linux_64-bit.tar.gz
mkdir bin && tar -xvzf vale_2.21.3_Linux_64-bit.tar.gz -C bin
export PATH=./bin:"$PATH"
```

Sync Vale once to get the right packages:

```bash
vale sync
```

Then you can use it on the docs directory to find text inconsistencies:

```bash
vale docs
```
