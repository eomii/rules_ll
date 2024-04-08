{
  description = "rules_ll development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  nixConfig = {
    bash-prompt-prefix = "(rules_ll) ";
    bash-prompt = ''\[\033]0;\u@\h:\w\007\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\]'';
    bash-prompt-suffix = " ";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , pre-commit-hooks
    , flake-parts
    , ...
    } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; }
      {
        systems = [
          "x86_64-linux"
        ];
        imports = [
          inputs.pre-commit-hooks.flakeModule
          ./flake-module.nix
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
            llvmPackages = pkgs.llvmPackages_17;
            bazel = pkgs.bazel_7;
            tag = "latest";
            ll = import ./devtools/ll.nix { inherit pkgs tag bazel; };
          in
          {
            _module.args.pkgs = import self.inputs.nixpkgs {
              inherit system;
              # CUDA support
              config.allowUnfree = true;
              config.cudaSupport = true;
            };
            pre-commit.settings = { inherit hooks; };
            rules_ll.settings.actionEnv =
              let
                openssl = (pkgs.openssl.override { static = true; });
              in
              self.lib.action-env {
                inherit pkgs;
                LL_CFLAGS = "-I${openssl.dev}/include";
                LL_LDFLAGS = "-L${openssl.out}/lib";
              };
            packages = {
              ci-image = import ./rbe/image.nix {
                inherit pkgs llvmPackages bazel tag;
              };
            };
            devShells.default = pkgs.mkShell {
              nativeBuildInputs = [
                bazel
                ll
                pkgs.git
                (pkgs.python3.withPackages (pylib: [
                  pylib.mkdocs-material
                ]))
                pkgs.mkdocs
                pkgs.vale
                pkgs.go

                # Cloud tooling
                pkgs.cilium-cli
                pkgs.kubectl
                pkgs.pulumi
                pkgs.skopeo
                pkgs.tektoncd-cli
              ];
              shellHook = ''
                # Generate the .pre-commit-config.yaml symlink when entering the
                # development shell.
                ${config.pre-commit.installationScript}

                # Generate .bazelrc.ll which containes action-env configuration
                # when rules_ll is run from a nix environment.
                ${config.rules_ll.installationScript}

                # Ensure that the ll command points to our ll binary.
                [[ $(type -t ll) == "alias" ]] && unalias ll

                # Ensure that the bazel command points to our custom wrapper.
                [[ $(type -t bazel) == "alias" ]] && unalias bazel

                # Prevent rules_cc from using anything other than clang.
                export CC=clang

                # Probably a bug in nix. Setting LD=ld.lld here doesn't work.
                export LD=${llvmPackages.lld}/bin/ld.lld

                # Java needs to be the same version as in the Bazel wrapper.
                export JAVA_HOME=${pkgs.jdk17_headless}/lib/openjdk

                # Prettier color output for the ls command.
                alias ls='ls --color=auto'
              '';
            };
          };
      } // {
      templates = {
        default = {
          path = "${./templates/default}";
          description = "A basic rules_ll workspace";
        };
      };
      flakeModule = ./flake-module.nix;
      lib = { action-env = import ./modules/rules_ll-action-env.nix; };
    };
}
