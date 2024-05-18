{
  description = "rules_ll examples";

  nixConfig = {
    bash-prompt-prefix = "(rules_ll) ";
    bash-prompt = ''\[\033]0;\u@\h:\w\007\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\]'';
    bash-prompt-suffix = " ";
  };

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs";
      follows = "nativelink/nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nativelink = {
      url = "github:TraceMachina/nativelink/75105df746c626da76f74e412764e6755296a8ab";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-parts.follows = "flake-parts";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
    };
    rules_ll = {
      # If you use this file as template, substitute the line below with this,
      # where `<version>` is the version of rules_ll you want to use:
      #
      #   rules_ll.url = "github:eomii/rules_ll/<version>";
      url = path:../;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nativelink.follows = "nativelink";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
    };
  };

  outputs =
    { self
    , rules_ll
    , flake-parts
    , nativelink
    , ...
    } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; }
      {
        systems = [
          "x86_64-linux"
        ];
        imports = [
          inputs.nativelink.flakeModule
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
            rules_ll.settings.llEnv = rules_ll.lib.defaultLlEnv {
              inherit pkgs;
              LL_CFLAGS = "-I${openssl.dev}/include";
              LL_LDFLAGS = "-L${openssl.out}/lib";
            };
            devShells.default = pkgs.mkShell {
              nativeBuildInputs =
                let
                  bazel = pkgs.writeShellScriptBin "bazel" ''
                    unset TMPDIR TMP
                    exec ${pkgs.bazelisk}/bin/bazelisk "$@"
                  '';
                in
                [ bazel pkgs.kubectl ];
              shellHook = ''
                # Generate .bazelrc.ll which containes action-env
                # configuration when rules_ll is run from a nix environment.
                # Has no effect in the examples as it's already handled by the
                # top-level flake.
                ${config.rules_ll.installationScript}

                # Generate .bazelrc.lre which configures the LRE toolchains.
                # Has no effect in the examples as it's already handled by the
                # top-level flake.
                ${config.local-remote-execution.installationScript}

                # Prevent rules_cc from using anything other than clang.
                export CC=clang

                # Probably a bug in nix. Setting LD=ld.lld here doesn't work.
                export LD=${pkgs.llvmPackages_17.lld}/bin/ld.lld

                # Java needs to be the same version as in the Bazel wrapper.
                export JAVA_HOME=${pkgs.jdk17_headless}/lib/openjdk
              '';
            };
          };
      };
}
