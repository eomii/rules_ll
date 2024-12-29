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
    # TODO(aaronmondal): This is currently required by LRE even if we don't use
    #                    Rust. Fix this upstream.
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nativelink = {
      url = "github:TraceMachina/nativelink/b1df876fd64d60d5d1b6cb15a50e934923ab82bf";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-parts.follows = "flake-parts";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
      inputs.rust-overlay.follows = "rust-overlay";
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
      inputs.rust-overlay.follows = "rust-overlay";
    };
  };

  outputs =
    { self
    , rules_ll
    , flake-parts
    , nativelink
    , rust-overlay
    , ...
    } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; }
      {
        systems = [
          "x86_64-linux"
        ];
        imports = [
          inputs.nativelink.flakeModule.local-remote-execution
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
            _module.args.pkgs = import self.inputs.nixpkgs {
              inherit system;
              overlays = [
                nativelink.overlays.lre
                (import ../patches/nixpkgs-disable-ratehammering-pulumi-tests.nix)
                (import rust-overlay)
              ];
              # CUDA support
              config.allowUnfree = true;
              config.cudaSupport = true;
            };
            local-remote-execution.settings = {
              inherit (pkgs.lre.lre-cc.meta) Env;
            };
            rules_ll.settings = {
              Env = rules_ll.lib.defaultLlEnv {
                inherit pkgs;
                LL_CFLAGS = "-I${openssl.dev}/include";
                LL_LDFLAGS = "-L${openssl.out}/lib";
              };
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
              '';
            };
          };
      };
}
