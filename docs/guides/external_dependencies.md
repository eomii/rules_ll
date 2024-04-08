# External dependencies

You can make dependencies from the Nix package repository available to `ll_*`
targets in a hermetic, reproducible manner.

## A word of caution

The external dependency mechanism in `rules_ll` lets you import external
dependencies, but it globally affects all `ll_*` compile commands.

Any change to an external dependency invalidates all caches and causes a full
rebuild of all toolchains.

## Example

The `rules_ll` flake-parts module exposes an `actionEnv` attribute which you can
use to set custom Bazel `--action-env` attributes in your generated
`.bazelrc.ll`. Technically you can use the `.bazelrc.ll` generation logic to
generate arbitrary `.bazelrc.*` fragments. If you intend to use it with
`rules_ll`s Bazel toolchains you should use the `rules_ll.lib.action-env`
function which lets you specify `LL_CFLAGS` and `LL_LDFLAGS` and handles all
other environment variables automatically.

Since `rules_ll` uses the `clang-linker-wrapper` as its linking tool you don't
need to add `-Wl,...` to flags in `LL_LDFLAGS`.

Don't use spaces in these flags and separate different flags with colons.

<!-- markdownlint-disable code-block-style -->
=== "Static linkage"

    ```nix title="flake.nix" hl_lines="40 45 46"
    {
      inputs = {
        nixpkgs.url = "github:nixos/nixpkgs";
        flake-parts = {
          url = "github:hercules-ci/flake-parts";
          inputs.nixpkgs-lib.follows = "nixpkgs";
        };
        rules_ll = {
          # If you use this file as template, substitute the line below with this,
          # where `<version>` is the version of rules_ll you want to use:
          #
          #   rules_ll.url = "github:eomii/rules_ll/<version>";
          url = "github:eomii/rules_ll";
          inputs.nixpkgs.follows = "nixpkgs";
          inputs.flake-parts.follows = "flake-parts";
        };
      };
      outputs =
        { self
        , rules_ll
        , flake-parts
        , ...
        } @ inputs:
        flake-parts.lib.mkFlake { inherit inputs; }
          {
            systems = [
              "x86_64-linux"
            ];
            imports = [
              inputs.rules_ll.flakeModule
            ];
            perSystem =
              { config
              , pkgs
              , system
              , lib
              , ...
              }:
              let
                openssl = (pkgs.openssl.override { static = true; });
              in
              {
                rules_ll.settings.actionEnv = rules_ll.lib.action-env {
                  inherit pkgs;
                  LL_CFLAGS = "-I${openssl.dev}/include";
                  LL_LDFLAGS = "-L${openssl.out}/lib";
                };
                devShells.default = pkgs.mkShell {
                  nativeBuildInputs = [ pkgs.bazel_7 ];
                  shellHook = ''
                    # Generate .bazelrc.ll which containes action-env
                    # configuration when rules_ll is run from a nix environment.
                    ${config.rules_ll.installationScript}

                    # Prevent rules_cc from using anything other than clang.
                    export CC=clang

                    # Probably a bug in nix. Setting LD=ld.lld here won't work.
                    export LD=${pkgs.llvmPackages_17.lld}/bin/ld.lld

                    # Java needs to be the same version as in the Bazel wrapper.
                    export JAVA_HOME=${pkgs.jdk17_headless}/lib/openjdk
                  '';
                };
              };
          };
    ```

=== "Dynamic linkage"

    ```nix title="flake.nix" hl_lines="42 43"
    {
      inputs = {
        nixpkgs.url = "github:nixos/nixpkgs";
        flake-parts = {
          url = "github:hercules-ci/flake-parts";
          inputs.nixpkgs-lib.follows = "nixpkgs";
        };
        rules_ll = {
          # If you use this file as template, substitute the line below with this,
          # where `<version>` is the version of rules_ll you want to use:
          #
          #   rules_ll.url = "github:eomii/rules_ll/<version>";
          url = "github:eomii/rules_ll";
          inputs.nixpkgs.follows = "nixpkgs";
          inputs.flake-parts.follows = "flake-parts";
        };
      };
      outputs =
        { self
        , rules_ll
        , flake-parts
        , ...
        } @ inputs:
        flake-parts.lib.mkFlake { inherit inputs; }
          {
            systems = [
              "x86_64-linux"
            ];
            imports = [
              inputs.rules_ll.flakeModule
            ];
            perSystem =
              { config
              , pkgs
              , system
              , lib
              , ...
              }:
              {
                rules_ll.settings.actionEnv = rules_ll.lib.action-env {
                  inherit pkgs;
                  LL_CFLAGS = "-I${pkgs.openssl.dev}/include";
                  LL_LDFLAGS = "-L${pkgs.openssl.out}/lib:-rpath=${pkgs.openssl.out}/lib";
                };
                devShells.default = pkgs.mkShell {
                  nativeBuildInputs = [ pkgs.bazel_7 ];
                  shellHook = ''
                    # Generate .bazelrc.ll which containes action-env
                    # configuration when rules_ll is run from a nix environment.
                    ${config.rules_ll.installationScript}

                    # Prevent rules_cc from using anything other than clang.
                    export CC=clang

                    # Probably a bug in nix. Setting LD=ld.lld here won't work.
                    export LD=${pkgs.llvmPackages_17.lld}/bin/ld.lld

                    # Java needs to be the same version as in the Bazel wrapper.
                    export JAVA_HOME=${pkgs.jdk17_headless}/lib/openjdk
                  '';
                };
              };
          };
    ```
<!-- markdownlint-enable code-block-style -->

You can see the values of `LL_CFLAGS` and `LL_LDFLAGS` in the generated
`.bazelrc.ll`:

<!-- markdownlint-disable code-block-style -->
=== "Static linkage"

    ```shell
    cat .bazelrc.ll $LL_CFLAGS
    # ...
    #
    # build --action_env=LL_CFLAGS=-I/nix/store/<...>-openssl-<version>-dev/include
    # build --action_env=LL_LDFLAGS=-L/nix/store/<...>-openssl-<version>/lib
    ```

=== "Dynamic linkage"

    ```shell
    # ...
    #
    # build --action_env=LL_CFLAGS=-I/nix/store/<...>-openssl-<version>-dev/include
    # build --action_env=LL_LDFLAGS=-L/nix/store/<...>-openssl-<version>/lib:-rpath=/nix/store/<...>-openssl-<version>/lib
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
- It's possible to reference paths to non-nix dependencies in these flags, but
  doing so breaks the hermeticity and reproducibility of the build.
- Referencing paths that contain headers supplied by `rules_ll` itself such as
  `/usr/include` or `${pkgs.libcxx}/include` overrides parts of the internal
  `ll_*` toolchains and breaks all `ll_*` targets.
- Link actions add all `-rpath` values from `LL_LDFLAGS` to every target even if
  the target doesn't actually link the corresponding library. This affects
  `ll_binary`, `ll_test` and `ll_library` with `emit = ["shared_object"]`.
