{
  description = "your_project";

  nixConfig = {
    bash-prompt-prefix = "(rules_ll) ";
    bash-prompt = ''\[\033]0;\u@\h:\w\007\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\]'';
    bash-prompt-suffix = " ";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
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
      url = "github:aaronmondal/nativelink/update-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-parts.follows = "flake-parts";
    };
    rules_ll = {
      url = "github:eomii/rules_ll";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-parts.follows = "flake-parts";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
      inputs.nativelik.follows = "nativelink";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , pre-commit-hooks
    , flake-parts
    , rules_ll
    , ...
    } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; }
      {
        systems = [
          "x86_64-linux"
        ];
        imports = [
          inputs.pre-commit-hooks.flakeModule
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
            hooks = import ./pre-commit-hooks.nix { inherit pkgs; };
            tag = "latest";
          in
          {
            _module.args.pkgs = import self.inputs.nixpkgs {
              inherit system;
              # CUDA support
              # config.allowUnfree = true;
              # config.cudaSupport = true;
            };
            pre-commit.settings = { inherit hooks; };
            rules_ll.settings.actionEnv =
              let
                openssl = (pkgs.openssl.override { static = true; });
              in
              rules_ll.lib.action-env {
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

                # Probably a bug in nix. Setting LD=ld.lld here doesn't work.
                export LD=${pkgs.llvmPackages_17.lld}/bin/ld.lld

                # Java needs to be the same version as in the Bazel wrapper.
                export JAVA_HOME=${pkgs.jdk17_headless}/lib/openjdk
              '';
            };
          };
      };
}
