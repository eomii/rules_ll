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

        nixpkgs-patched = (import nixpkgs { inherit system; }).applyPatches {
          name = "nixpkgs-patched";
          src = nixpkgs;
          patches = [ ./patches/nix_fix_linkerscript.diff ];
        };

        pkgs = import nixpkgs-patched { inherit system; };

        pkgsUnfree = import nixpkgs-patched {
          inherit system;
          config.allowUnfree = true;
        };

        hooks = import ./pre-commit-hooks.nix {
          inherit pkgs;
        };

        wrappedBazel = (import ./bazel-wrapper/default.nix {
          inherit pkgs pkgsUnfree;
          unfree = false;
          cc = pkgs.llvmPackages_15.clang;
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
          cc = pkgs.llvmPackages_15.clang;
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
                export LD=${pkgs.llvmPackages_15.lld}/bin/ld.lld

                # Prettier color output for the ls command.
                alias ls='ls --color=auto'
              '';
            }];
          }
        );

        bazelToolchains = import ./rbe/default.nix { inherit pkgs; };

        rbegen = pkgs.writeShellScriptBin "rbegen" ''
          # Make sure to only use this tool from the root directory of rules_ll.
          # You need a local docker registry running to regenerate the rbe
          # configuration:
          # docker run -d -p 5000:5000 --restart=always --name registry registry:2

          # Deliberately build the image manually and use "result" instead of
          # the derivation to prevent nix from building the image unless
          # explicitly asked to.

          nix build .#ci-image

          ${pkgs.skopeo}/bin/skopeo \
              --insecure-policy \
              copy \
              --dest-tls-verify=false \
              "docker-archive://$(realpath result)" \
              "docker://localhost:5000/rules_ll_remote"

          ${bazelToolchains}/bin/rbe_configs_gen \
              --toolchain_container=localhost:5000/rules_ll_remote \
              --exec_os=linux \
              --target_os=linux \
              --bazel_version=${wrappedBazel.version} \
              --output_src_root=$(pwd) \
              --output_config_path=rbe/default \
              --bazel_path=${wrappedBazel.baze_ll}/bin/bazel \
              --cpp_env_json=${self}/rbe/rbeconfig.json
        '';

      in
      {

        packages = {
          ci-image = import ./rbe/image.nix { inherit pkgs wrappedBazel; };
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
              rbegen
              pkgs.git
              (pkgs.python3.withPackages (pylib: [
                pylib.mkdocs-material
              ]))
              pkgs.mkdocs
              pkgs.vale
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
