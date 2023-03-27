# Contributing

`rules_ll` uses code-quality tools for a consistent style across the repository.

## Pre-commit hooks

Use the `rules_ll` development shell to get the various tools you need to work
on the project:

```bash title="(from within the rules_ll root directory)"
nix develop .#dev
```

The flake automatically sets up pre-commit in the shell which run on every local
commit. You can also run the hooks manually:

```bash title="(from within the rules_ll root directory)"
nix flake check -L
```

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

The examples at `rules_ll/examples` also act as tests for the project. If you
don't use `devenv` make sure to run the examples from the flake in the
`examples` directory:

```bash title="(from within the rules_ll/examples directory)"
nix develop
```

Heterogeneous tests fail on machines without the corresponding GPU, but they
should still produce executables:

```bash title="(from within the rules_ll/examples directory)"
# Should pass on all machines.
bazel test cpp

# Should pass on machines with supported Nvidia GPUs.
bazel test nvptx

# Should pass on machines with supported AMD GPUs.
bazel test amdgpu

# Even if some of these tests fail, they should all build and run.
bazel test all
```
