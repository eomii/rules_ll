{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/6f1d04bdb55d6160958430f594022b73b7e20711.tar.gz") { }
}:

let
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
in
pkgs.mkShell.override
{
  stdenv = pkgs.clang15Stdenv;
}
{

  buildInputs = [
    pkgs.bazelisk
    pkgs.git
    pkgs.python3
    pkgs.which
    pkgs.llvmPackages_15.lld
    pkgs.libxcrypt
    pkgs.glibc
    bazel
  ];

  shellHook = "export LD=ld.lld";
}
