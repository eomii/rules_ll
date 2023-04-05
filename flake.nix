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

  outputs = { self, nixpkgs, flake-utils, devenv, pre-commit-hooks-nix, ... } @ inputs:
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

          baze_ll = import ./baze_ll/baze_ll.nix { inherit pkgs; };

          bazel = { unfree ? false }: pkgs.writeShellScriptBin "bazel" (''
            # Add the nix cflags and ldflags to the Bazel action envs.
            # This is safe to do since the Nix environment is reproducible.
            LL_NIX_CFLAGS_COMPILE=-isystem${pkgs.glibc.dev}/include:-isystem${pkgs.libxcrypt}/include
            LL_NIX_LDFLAGS=-L${pkgs.glibc}/lib:-L${pkgs.libxcrypt}/lib

            # These environment variables may be modified from outside of
            # the bazel invocation.
            LL_CFLAGS=''${LL_CFLAGS+$LL_CFLAGS:}$LL_NIX_CFLAGS_COMPILE
            LL_LDFLAGS=''${LL_LDFLAGS+$LL_LDFLAGS:}$LL_NIX_LDFLAGS

            # This must always be the linker from the glibc we compile
            # and link against.
            LL_DYNAMIC_LINKER=${pkgs.glibc}/lib/ld-linux-x86-64.so.2

            # Flags for AMD dependencies.
            LL_AMD_INCLUDES=-isystem${pkgs.libdrm.dev}/include:-isystem${pkgs.libdrm.dev}/include/libdrm:-isystem${pkgs.elfutils.dev}/include:-isystem${pkgs.numactl}/include:-isystem${pkgs.libglvnd.dev}/include:-isystem${pkgs.xorg.libX11.dev}/include:-isystem${pkgs.xorg.xorgproto}/include
            LL_AMD_LIBRARIES=-L${pkgs.libdrm}/lib:-L${pkgs.numactl}/lib:-L=${pkgs.libglvnd}/lib:-L${pkgs.elfutils.out}/lib:-L${pkgs.libglvnd}/lib:-L${pkgs.xorg.libX11}/lib
            LL_AMD_RPATHS=-rpath=${pkgs.libdrm}/lib:-rpath=${pkgs.numactl}/lib:-rpath=${pkgs.libglvnd}/lib:-rpath=${pkgs.elfutils.out}/lib:-rpath=${pkgs.libglvnd}/lib:-rpath=${pkgs.xorg.libX11}/lib

          '' + (if unfree then ''
            # Flags for CUDA dependencies.
            LL_CUDA_TOOLKIT=${pkgsUnfree.cudaPackages_12.cudatoolkit}
            LL_CUDA_RUNTIME=${pkgsUnfree.cudaPackages_12.cudatoolkit.lib}
            LL_CUDA_DRIVER=${pkgsUnfree.linuxPackages_6_1.nvidia_x11}
          '' else "") + ''

                # Only used by rules_cc
                BAZEL_CXXOPTS="-std=c++17:-O3:-nostdinc++:-nostdlib++:-isystem${pkgs.llvmPackages_15.libcxx.dev}/include/c++/v1"
                BAZEL_LINKOPTS="-L${pkgs.llvmPackages_15.libcxx}/lib:-L${pkgs.llvmPackages_15.libcxxabi}/lib:-lc++:-Wl,-rpath,${pkgs.llvmPackages_15.libcxx}/lib,-rpath,${pkgs.llvmPackages_15.libcxxabi}/lib"

                if [[
                    "$1" == "build" ||
                    "$1" == "coverage" ||
                    "$1" == "run" ||
                    "$1" == "test"
                ]]; then
                    ${baze_ll}/bin/bazel $1 \
                        --action_env=LL_CFLAGS=$LL_CFLAGS \
                        --action_env=LL_LDFLAGS=$LL_LDFLAGS \
                        --action_env=LL_DYNAMIC_LINKER=$LL_DYNAMIC_LINKER \
                        --action_env=LL_AMD_INCLUDES=$LL_AMD_INCLUDES \
                        --action_env=LL_AMD_LIBRARIES=$LL_AMD_LIBRARIES \
                        --action_env=LL_AMD_RPATHS=$LL_AMD_RPATHS \
                        --action_env=LL_CUDA_TOOLKIT=$LL_CUDA_TOOLKIT \
                        --action_env=LL_CUDA_RUNTIME=$LL_CUDA_RUNTIME \
                        --action_env=LL_CUDA_DRIVER=$LL_CUDA_DRIVER \
                        --action_env=BAZEL_CXXOPTS=$BAZEL_CXXOPTS \
                        --action_env=BAZEL_LINKOPTS=$BAZEL_LINKOPTS \
                        ''${@:2}
                else
                    ${baze_ll}/bin/bazel $@
                fi
              '');

          image =
            { ll_env ? [
                # Set custom LL_CFLAGS and LL_LDFALAGS here using nix template
                # expansion and they will be made available via the external
                # dependency mechanism.
                "LL_CFLAGS="
                "LL_LDFLAGS="
              ]
            }: pkgs.dockerTools.buildLayeredImage {
              name = "rules_ll_remote";
              tag = "latest";

              contents = [
                # The default shell environment.
                (bazel { unfree = false; })

                # Minimal user setup. Required by Bazel.
                pkgs.fakeNss

                # Required for communication with trusted sources.
                pkgs.cacert

                # Toolchain for rules_cc.
                pkgs.llvmPackages_15.clang
                pkgs.llvmPackages_15.compiler-rt
                pkgs.llvmPackages_15.libcxx
                pkgs.llvmPackages_15.libcxxabi
                pkgs.llvmPackages_15.libunwind
                pkgs.llvmPackages_15.lld
                pkgs.llvmPackages_15.stdenv

                # Tools that we would usually forward from the host.
                pkgs.bash
                pkgs.coreutils
              ];

              extraCommands = ''
                mkdir rules_ll
                cp -r ${./.}/* rules_ll

              '';

              config = {
                Cmd = [ "ls" "/nix/store" ];
                WorkingDir = "/rules_ll/examples";
                Env = [
                  "CC=clang"
                  "LD=ld.lld"
                  "LD_LIBRARY_PATH=/lib"
                ] ++ ll_env;
              };
            };

          hooks = import ./pre-commit-hooks.nix { inherit pkgs; };

        in
        rec {

          packages = {
            default = baze_ll;
            test_image =
              let openssl = (pkgs.openssl.override { static = true; }); in
              image {
                ll_env = [
                  "LL_CFLAGS=-I${openssl.dev}/include"
                  "LL_CFLAGS=-I${openssl.out}/lib"
                ];
              };
          };

          checks = {
            pre-commit-check = pre-commit-hooks-nix.lib.${system}.run {
              src = ./.;
              inherit hooks;
            };
          };

          devShells = {
            default = mkLlShell { };
            unfree = mkLlShell { unfree = true; };
            dev = mkLlShell {
              unfree = true;
              deps = [
                pkgs.shellcheck
                pkgs.git
                (pkgs.python3.withPackages (pylib: [
                  pylib.mkdocs-material
                ]))
                pkgs.mkdocs
                pkgs.pre-commit
                pkgs.which
                pkgs.vale
              ];
            };
          };

          mkLlShell = ({ unfree ? false, deps ? [ ], env ? { } }: devenv.lib.mkShell {
            inherit inputs pkgs;

            modules = [{
              pre-commit = { inherit hooks; };

              inherit env;

              packages = [
                # Host toolchain.
                # pkgs.bazelisk
                (bazel { inherit unfree; })
                pkgs.llvmPackages_15.clang
                pkgs.llvmPackages_15.compiler-rt
                pkgs.llvmPackages_15.libcxx
                pkgs.llvmPackages_15.libcxxabi
                pkgs.llvmPackages_15.libunwind
                pkgs.llvmPackages_15.lld
                pkgs.llvmPackages_15.stdenv
                pkgs.libxcrypt

                # Heterogeneous programming.

                # Required by the ROCT-Thunk-Interface.
                pkgs.libdrm
                pkgs.numactl

                # Required by the ROCR-Runtime.
                pkgs.elfutils

                # Required by the AMD-OpenCL-Runtime.
                pkgs.libglvnd
                pkgs.xorg.libX11
                pkgs.xorg.xorgproto

                # Custom wrappers for rules_ll.
                ll
              ] ++ (if unfree then [
                pkgsUnfree.linuxPackages_6_1.nvidia_x11
                pkgsUnfree.cudaPackages_12.cudatoolkit
              ] else [ ]) ++ deps;

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
          });
        });
}
