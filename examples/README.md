# `rules_ll` examples

These examples operate as tests for `rules_ll` and to showcase various
functionality.

## Note for `rules_ll` developers

Since the example flake depends on a relative path to the `rules_ll` root
directory git doesn't track the flake lockfile here at the moment.

Unfortunately, adding the lockfile to `.gitignore` breaks direnv/devenv at the
moment and a `git update-index --skip-worktree` or similar doesn't seem to work
either.
