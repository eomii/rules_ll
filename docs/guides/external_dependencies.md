# External dependencies

You can make dependencies from the Nix package repository available to `ll_*`
targets in a hermetic, reproducible manner.

## A word of caution

The external dependency mechanism in `rules_ll` lets you import external
dependencies, but it globally affects all `ll_*` compile commands.

Any change to an external dependency invalidates all caches and causes a full
rebuild of all toolchains.

## Example

The `mkLlShell` wrapper exposes an `env` attribute that you can use to set the
`LL_CFLAGS` and `LL_LDFLAGS` environment variables. Since `rules_ll` uses the
`clang-linker-wrapper` as its linking tool you don't need to add `-Wl,...` to
flags in `LL_LDFLAGS`. Don't use spaces in these flags and separate different
flags with colons.

<!-- markdownlint-disable code-block-style -->
=== "Static linkage"

    ```nix title="flake.nix" hl_lines="16 25 26"
    {
      inputs = {
        nixpkgs.url = "github:nixos/nixpkgs";
        flake-utils.url = "github:numtide/flake-utils";
        # Substitute <version> with the current version of rules_ll.
        rules_ll.url = "github:eomii/rules_ll/<version>";
      };

      outputs = { self, nixpkgs, flake-utils, rules_ll, ... } @ inputs:
        flake-utils.lib.eachSystem [
          "x86_64-linux"
        ]
          (system:
            let
              pkgs = import nixpkgs { inherit system; };
              openssl_static = (pkgs.openssl.override { static = true; });
              ll_shell = rules_ll.mkLlShell.${system};
            in
            {
              devShells = {
                default = ll_shell {
                  unfree = true;  # Optionally enable CUDA toolchains.
                  deps = [ ];
                  env = {
                    LL_CFLAGS = "-I${openssl_static.dev}/include";
                    LL_LDFLAGS = "-L${openssl_static.out}/lib";
                  };
                };
              };
            });
    }
    ```

=== "Dynamic linkage"

    ```nix title="flake.nix" hl_lines="16 25 26"
    {
      inputs = {
        nixpkgs.url = "github:nixos/nixpkgs";
        flake-utils.url = "github:numtide/flake-utils";
        # Substitute <version> with the current version of rules_ll.
        rules_ll.url = "github:eomii/rules_ll/<version>";
      };

      outputs = { self, nixpkgs, flake-utils, rules_ll, ... } @ inputs:
        flake-utils.lib.eachSystem [
          "x86_64-linux"
        ]
          (system:
            let
              pkgs = import nixpkgs { inherit system; };
              openssl_dynamic = pkgs.openssl;
              ll_shell = rules_ll.mkLlShell.${system};
            in
            {
              devShells = {
                default = ll_shell {
                  unfree = true;  # Optionally enable CUDA toolchains.
                  deps = [ ];
                  env = {
                    LL_CFLAGS = "-I${openssl_dynamic.dev}/include";
                    LL_LDFLAGS = "-L${openssl_dynamic.out}/lib:-rpath=${openssl_dynamic.out}/lib";
                  };
                };
              };
            });
    }
    ```
<!-- markdownlint-enable code-block-style -->

You can see the values of `LL_CFLAGS` and `LL_LDFLAGS` by printing them like any
other environment variable:

<!-- markdownlint-disable code-block-style -->
=== "Static linkage"

    ```shell
    echo $LL_CFLAGS
    # -I/nix/store/<...>-openssl-<version>-dev/include

    echo $LL_LDFLAGS
    # -L/nix/store/<...>-openssl-<version>/lib
    ```

=== "Dynamic linkage"

    ```shell
    echo $LL_CFLAGS
    # -I/nix/store/<...>-openssl-<version>-dev/include

    echo $LL_LDFLAGS
    # -L/nix/store/<...>-openssl-<version>/lib:-rpath=/nix/store/<...>-openssl-<version>/lib
    ```
<!-- markdownlint-enable code-block-style -->

You can now add the library via `link_flags` or `shared_object_link_flags`:

```python title="BUILD.bazel"
load("@rules_ll//ll:defs.bzl", "ll_binary")

ll_binary(
    name = "my_externally_dependent_executable",
    srcs = ["main.cpp"],
    link_flags = [
        "-lcrypto",  # Default linkage as set in the flake.
        # "-l:libcrypto.a",  # Explicit static linkage.
        # "-l:libcrypto.so",  # Explicit dynamic linkage.
    ],
)
```

Keep in mind that `LL_CFLAGS` and `LL_LDFLAGS` globally affect `ll_*` targets:

- Every compile action can see all headers in `LL_CFLAGS`. If two dependencies
  contain headers with the same name your builds might break with confusing
  errors. If you suspect a wrong header inclusion you can add `-H` to the
  `compile_flags` attribute of your target to print the full inclusion chain.
- Referencing paths to non-nix dependencies in these flags breaks the
  hermeticity and reproducibility of the build.
- Referencing paths that contain headers supplied by `rules_ll` itself such as
  `/usr/include` or `${pkgs.libcxx}/include` overrides parts of the internal
  `ll_*` toolchains and breaks all `ll_*` targets.
- Link actions add all `-rpath` values from `LL_LDFLAGS` to every target even if
  the target doesn't actually link the corresponding library. This affects
  `ll_binary`, `ll_test` and `ll_library` with `emit = ["shared_object"]`.
