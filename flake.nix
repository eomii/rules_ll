{
  description = "rules_ll development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  nixConfig = {
    bash-prompt-prefix = "(rules_ll) ";
    bash-prompt = ''\[\033]0;\u@\h:\w\007\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\]'';
    bash-prompt-suffix = " ";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      bazel = pkgs.writeShellScriptBin "bazel" ''
        # Add the nix cflags and ldflags to the Bazel action envs.
        # This is safe to do since the Nix environment is reproducible.

        LL_NIX_CFLAGS_COMPILE=`echo $NIX_CFLAGS_COMPILE | tr ' ' ':'`
        LL_NIX_LDFLAGS=`echo $NIX_LDFLAGS | tr ' ' ':'`

        LL_CFLAGS=''${LL_CFLAGS+$LL_CFLAGS:}$LL_NIX_CFLAGS_COMPILE
        LL_LDFLAGS=''${LL_LDFLAGS+$LL_LDFLAGS:}$LL_NIX_LDFLAGS

        if [[
            "$1" == "build" ||
            "$1" == "coverage" ||
            "$1" == "run" ||
            "$1" == "test"
        ]]; then
            bazelisk $1 \
                --action_env=LL_CFLAGS=$LL_CFLAGS \
                --action_env=LL_LDFLAGS=$LL_LDFLAGS \
                ''${@:2}
        else
            bazelisk $@
        fi
        '';
      ll = pkgs.writeShellScriptBin "ll" ''
        if [[ "$1" == "init" ]]; then
          # Only appending for now to be nondestructive.
          echo "# Empty." >> WORKSPACE.bazel
          head -1 ${./.bazelversion} >> .bazelversion
          head -1 ${./examples/MODULE.bazel} >> MODULE.bazel
          cat ${./examples/.bazelrc} >> .bazelrc
        else
          echo "Command not understood."
        fi
      '';
    in rec {
      defaultPackage = devShell;
      devShell = pkgs.mkShell.override {
        # Toggle this to test building clang with clang and gcc host compilers.
        stdenv = pkgs.clang15Stdenv;
      } {
        buildInputs = [
          pkgs.bazelisk
          pkgs.git
          pkgs.python3
          pkgs.pre-commit
          pkgs.which
          pkgs.llvmPackages_15.lld
          pkgs.libxcrypt
          pkgs.glibc
          bazel
          ll
        ];
        shellHook = ''
          export LD=ld.lld
          alias ls='ls --color=auto'
        '';
      };
  });
}
