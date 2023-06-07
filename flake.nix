{
  description = "rules_ll development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    devenv.url = "github:cachix/devenv/latest";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
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
    , devenv
    , pre-commit-hooks-nix
    , ...
    } @ inputs:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
    ]
      (system:
      let

        pkgs = import nixpkgs { inherit system; };

        pkgsUnfree = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        hooks = import ./pre-commit-hooks.nix {
          inherit pkgs;
        };

        wrappedBazel = (import ./bazel-wrapper/default.nix {
          inherit pkgs pkgsUnfree;
          unfree = false;
          cc = pkgs.llvmPackages_16.clang;
          bazel = pkgs.bazel;
          ll_env = let openssl = (pkgs.openssl.override { static = true; }); in [
            "LL_CFLAGS=-I${openssl.dev}/include"
            "LL_LDFLAGS=-L${openssl.out}/lib"
          ];
        });

        # TODO: This is not pretty, but let's clean it up later.
        wrappedBazelUnfree = (import ./bazel-wrapper/default.nix {
          inherit pkgs pkgsUnfree;
          unfree = true;
          cc = pkgs.llvmPackages_16.clang;
          bazel = pkgs.bazel;
          ll_env = let openssl = (pkgs.openssl.override { static = true; }); in [
            "LL_CFLAGS=-I${openssl.dev}/include"
            "LL_LDFLAGS=-L${openssl.out}/lib"
          ];
        });

        llShell = (
          { unfree ? false
          , packages ? [ ]
          , env ? { }
          , hooks ? { }
          }:
          devenv.lib.mkShell {
            inherit inputs pkgs;

            modules = [{
              pre-commit = { inherit hooks; };

              inherit env;

              packages = [
                (
                  if !unfree
                  then wrappedBazel.baze_ll
                  else wrappedBazelUnfree.baze_ll
                )
              ] ++ packages;

              enterShell = ''
                # Ensure that the ll command points to our ll binary.
                [[ $(type -t ll) == "alias" ]] && unalias ll

                # Ensure that the bazel command points to our custom wrapper.
                [[ $(type -t bazel) == "alias" ]] && unalias bazel

                # Prevent rules_cc from using anything other than clang.
                export CC=clang

                # Probably a bug in nix. Setting LD=ld.lld here doesn't work.
                export LD=${pkgs.llvmPackages_16.lld}/bin/ld.lld

                # Java needs to be the same version as in the Bazel wrapper.
                export JAVA_HOME=${pkgs.jdk17_headless}/lib/openjdk

                # Prettier color output for the ls command.
                alias ls='ls --color=auto'
              '';
            }];
          }
        );

        # Development tooling for rules_ll.
        tag = "latest";
        ll = import ./devtools/ll.nix { inherit pkgs wrappedBazel tag; };

      in
      {

        packages = {
          ci-image = import ./rbe/image.nix { inherit pkgs wrappedBazel tag; };
        };

        checks = {
          pre-commit-check = pre-commit-hooks-nix.lib.${system}.run {
            src = ./.;
            inherit hooks;
          };
        };

        devShells = {
          default = llShell {
            unfree = true;
            packages = [
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
            inherit hooks;
          };
        };

        lib = { inherit llShell; };

      })
    //
    {
      templates = {
        default = {
          path = "${./templates/default}";
          description = "A basic rules_ll workspace";
        };
      };
    };
}
