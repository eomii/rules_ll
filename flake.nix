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

        in
        rec {

          packages = {
            default = devShells.default;
            unfree = devShells.unfree;
          };

          devShells = {
            default = devShellBuilder false; # Disable unfree packages.
            unfree = devShellBuilder true; # Enable unfree packages.
          };

          devShellBuilder = (unfree: pkgs.mkShell.override
            {
              # Toggle this to test building clang with clang and gcc host compilers.
              stdenv = pkgs.clang15Stdenv;
            }
            rec {
              bazel = pkgs.writeShellScriptBin "bazel" (''
                # Add the nix cflags and ldflags to the Bazel action envs.
                # This is safe to do since the Nix environment is reproducible.
                LL_NIX_CFLAGS_COMPILE=`echo $NIX_CFLAGS_COMPILE_FOR_TARGET | tr ' ' ':'`
                LL_NIX_LDFLAGS=`echo $NIX_LDFLAGS_FOR_TARGET | tr ' ' ':'`

                # Flags for AMD dependencies.
                LL_LIBDRM_INCLUDES=-isystem${pkgs.libdrm.dev}/include/libdrm
                LL_AMD_RPATHS=-rpath=${pkgs.libdrm}/lib:-rpath=${pkgs.numactl}/lib:-rpath=${pkgs.libglvnd}/lib:-rpath=${pkgs.elfutils}/lib:-rpath=${pkgs.libglvnd}/lib:-rpath=${pkgs.xorg.libX11}/lib

              '' + (if unfree then ''
                LL_CUDA=${pkgsUnfree.cudaPackages_12.cudatoolkit}
                LL_CUDA_RPATH=${pkgsUnfree.linuxPackages_6_1.nvidia_x11}/lib
              '' else "") + ''

                LL_CFLAGS=''${LL_CFLAGS+$LL_CFLAGS:}$LL_NIX_CFLAGS_COMPILE:$LL_LIBDRM_INCLUDES
                LL_LDFLAGS=''${LL_LDFLAGS+$LL_LDFLAGS:}$LL_NIX_LDFLAGS:$LL_AMD_RPATHS
                LL_DYNAMIC_LINKER=${pkgs.glibc}/lib/ld-linux-x86-64.so.2

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
              '');
              name = "rules_ll-shell";
              buildInputs = [
                # Host toolchain.
                pkgs.bazelisk
                pkgs.llvmPackages_15.clang
                pkgs.llvmPackages_15.compiler-rt
                pkgs.llvmPackages_15.libcxx
                pkgs.llvmPackages_15.libcxxabi
                pkgs.llvmPackages_15.libunwind
                pkgs.llvmPackages_15.lld
                pkgs.libxcrypt
                pkgs.glibc

                # Heterogeneous programming.

                # It's unintuitive that we would need libdrm, but the
                # ROCT-Thunk-Interface hard-depends on it.
                pkgs.libdrm

                # Required by the ROCT-Thunk-Interface.
                pkgs.numactl

                # Required by the ROCR-Runtime.
                pkgs.elfutils

                # Required by the AMD-OpenCL-Runtime.
                pkgs.libglvnd
                pkgs.xorg.libX11

                # Development dependencies. TODO: Move out of default flake.
                pkgs.shellcheck
                pkgs.git
                pkgs.python3
                pkgs.python310Packages.mkdocs-material
                pkgs.pre-commit
                pkgs.which
                pkgs.vale

                # Custom wrappers for rules_ll.
                bazel
                ll
              ] ++ (if unfree then [
                pkgsUnfree.linuxPackages_6_1.nvidia_x11
                pkgsUnfree.cudaPackages_12.cudatoolkit
              ] else [ ]);

              shellHook = ''
                # Ensure that the ll command points to our ll binary.
                [[ $(type -t ll) == "alias" ]] && unalias ll

                export LD=ld.lld
                alias ls='ls --color=auto'
              '';
            });
        });
}
