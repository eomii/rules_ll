{ pkgs
, LL_CFLAGS ? null
, LL_LDFLAGS ? null

  # We allow overriding these values in case the fairly agressively upstream
  # variants don't work.
, llvmPackages ? pkgs.llvmPackages_17
, nvidia_x11 ? pkgs.linuxKernel.packages.linux_latest_libre.nvidia_x11
, cudatoolkit ? pkgs.cudaPackages.cudatoolkit
, ...
}:

let
  lib = pkgs.lib;

  LL_NIX_CFLAGS_COMPILE = lib.concatStringsSep ":" [
    "-isystem${pkgs.glibc.dev}/include"
    "-isystem${pkgs.libxcrypt}/include"
  ];

  LL_NIX_LDFLAGS = lib.concatStringsSep ":" [
    "-L${pkgs.glibc}/lib"
    "-rpath=${pkgs.glibc}/lib"
    "-L${pkgs.libxcrypt}/lib"
  ];
in

[
  "LL_CFLAGS=${
    if isNull LL_CFLAGS
    then LL_NIX_CFLAGS_COMPILE
    else
      lib.concatStringsSep ":" [
        LL_CFLAGS
        LL_NIX_CFLAGS_COMPILE
      ]}"

  "LL_LDFLAGS=${
    if isNull LL_LDFLAGS
    then LL_NIX_LDFLAGS
    else
      lib.concatStringsSep ":" [
        LL_LDFLAGS
        LL_NIX_LDFLAGS
      ]}"

  # This must always be the linker from the glibc we compile and link against.
  "LL_DYNAMIC_LINKER=${pkgs.glibc}/lib/ld-linux-x86-64.so.2"

  # Flags for AMD dependencies.
  "LL_AMD_INCLUDES=${lib.concatStringsSep ":" [
    "-isystem${pkgs.libdrm.dev}/include"
    "-isystem${pkgs.libdrm.dev}/include/libdrm"
    "-isystem${pkgs.elfutils.dev}/include"
    "-isystem${pkgs.numactl.dev}/include"
    "-isystem${pkgs.libglvnd.dev}/include"
    "-isystem${pkgs.xorg.libX11.dev}/include"
    "-isystem${pkgs.xorg.xorgproto}/include"
  ]}"
  "LL_AMD_LIBRARIES=${lib.concatStringsSep ":" [
    "-L${pkgs.libdrm}/lib"
    "-rpath=${pkgs.libdrm}/lib"
    "-L${pkgs.numactl}/lib"
    "-rpath=${pkgs.numactl}/lib"
    "-L${pkgs.libglvnd}/lib"
    "-rpath=${pkgs.libglvnd}/lib"
    "-L${pkgs.elfutils.out}/lib"
    "-rpath=${pkgs.elfutils.out}/lib"
    "-L${pkgs.libglvnd}/lib"
    "-rpath=${pkgs.libglvnd}/lib"
    "-L${pkgs.xorg.libX11}/lib"
    "-rpath=${pkgs.xorg.libX11}/lib"
  ]}"

  # Flags for CUDA dependencies.
  "LL_CUDA_TOOLKIT=${lib.strings.optionalString pkgs.config.cudaSupport "${cudatoolkit}"}"
  "LL_CUDA_RUNTIME=${lib.strings.optionalString pkgs.config.cudaSupport "${cudatoolkit.lib}"}"
  "LL_CUDA_DRIVER=${lib.strings.optionalString pkgs.config.cudaSupport "${nvidia_x11}"}"
]
