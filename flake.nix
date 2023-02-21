{
  description = "rules_ll development environment";

  inputs = {
    # Temporary workaround.
    # nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs.url = "github:rrbutani/nixpkgs/fix/llvm-15-libcxx-linker-script-bug";
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
      # pkgs = import nixpkgs.legacyPackages.${system} {
      #   config = { allowUnfree = true; }; };
      pkgs = import nixpkgs {
        inherit system;
        # legacyPackages = ${system};
        config.allowUnfree = true;
      };
      bazel = pkgs.writeShellScriptBin "bazel" ''
        # Add the nix cflags and ldflags to the Bazel action envs.
        # This is safe to do since the Nix environment is reproducible.

        LL_NIX_CFLAGS_COMPILE=`echo $NIX_CFLAGS_COMPILE | tr ' ' ':'`
        LL_NIX_LDFLAGS=`echo $NIX_LDFLAGS_FOR_TARGET | tr ' ' ':'`

        LL_CFLAGS=''${LL_CFLAGS+$LL_CFLAGS:}$LL_NIX_CFLAGS_COMPILE
        LL_LDFLAGS=''${LL_LDFLAGS+$LL_LDFLAGS:}$LL_NIX_LDFLAGS
        LL_DYNAMIC_LINKER=${pkgs.glibc}/lib/ld-linux-x86-64.so.2
        LL_CUDA=${pkgs.cudaPackages_12.cudatoolkit}
        LL_CUDA_RPATH=${pkgs.linuxPackages_6_1.nvidia_x11}/lib

        # Only used by rules_cc
        BAZEL_CXXOPTS="-std=c++17:-O3:-nostdinc++:-nostdlib++:-isystem${pkgs.llvmPackages_15.libcxx.dev}/include/c++/v1"

        BAZEL_LINKOPTS="-L${pkgs.llvmPackages_15.libcxx}/lib:-L${pkgs.llvmPackages_15.libcxxabi}/lib:-lc++:-Wl,-rpath,${pkgs.llvmPackages_15.libcxx}/lib,-rpath,${pkgs.llvmPackages_15.libcxxabi}/lib"

        if [[
            "$1" == "build" ||
            "$1" == "coverage" ||
            "$1" == "run" ||
            "$1" == "test"
        ]]; then
            bazelisk $1 \
                --action_env=LL_CFLAGS=$LL_CFLAGS \
                --action_env=LL_LDFLAGS=$LL_LDFLAGS \
                --action_env=LL_DYNAMIC_LINKER=$LL_DYNAMIC_LINKER \
                --action_env=LL_CUDA=$LL_CUDA \
                --action_env=LL_CUDA_RPATH=$LL_CUDA_RPATH \
                --action_env=BAZEL_CXXOPTS=$BAZEL_CXXOPTS \
                --action_env=BAZEL_LINKOPTS=$BAZEL_LINKOPTS \
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
        name = "rules_ll-shell";
        buildInputs = [
          pkgs.llvmPackages_15.clang
          pkgs.llvmPackages_15.compiler-rt
          pkgs.llvmPackages_15.libcxx
          pkgs.llvmPackages_15.libcxxabi
          pkgs.llvmPackages_15.libunwind
          pkgs.llvmPackages_15.lld

          pkgs.linuxPackages_6_1.nvidia_x11
          pkgs.cudaPackages_12.cudatoolkit

          pkgs.shellcheck
          pkgs.bazelisk
          pkgs.git
          pkgs.python3
          pkgs.python310Packages.mkdocs-material
          pkgs.pre-commit
          pkgs.which
          pkgs.libxcrypt
          pkgs.glibc
          pkgs.vale

          bazel
          ll
        ];

        shellHook = ''
          # Ensure that the ll command points to our ll binary.
          [[ $(type -t ll) == "alias" ]] && unalias ll

          export LD=ld.lld
          alias ls='ls --color=auto'
        '';
      };
  });
}
