{ pkgs
, pkgsUnfree
, bazel
, cudaSupport ? false
, cudaPackages ? { }
, ll_env
, llvmPackages
}:

{
  env = ll_env;
  version = bazel.version;
  baze_ll = pkgs.writeShellScriptBin "bazel" ''

# The default compilation environment.
CC=${llvmPackages.clang}/bin/clang

# Add the nix cflags and ldflags to the Bazel action envs. This is safe to do
# since the Nix environment is reproducible.
${pkgs.lib.concatStringsSep "\n" ll_env}

LL_NIX_CFLAGS_COMPILE=${pkgs.lib.concatStringsSep ":" [
  "-isystem${pkgs.glibc.dev}/include"
  "-isystem${pkgs.libxcrypt}/include"
]}

LL_NIX_LDFLAGS=${pkgs.lib.concatStringsSep ":" [
  "-L${pkgs.glibc}/lib"
  "-rpath=${pkgs.glibc}/lib"
  "-L${pkgs.libxcrypt}/lib"
]}

# These environment variables may be modified from outside of the bazel
# invocation.
LL_CFLAGS=''${LL_CFLAGS+$LL_CFLAGS:}$LL_NIX_CFLAGS_COMPILE
LL_LDFLAGS=''${LL_LDFLAGS+$LL_LDFLAGS:}$LL_NIX_LDFLAGS

# This must always be the linker from the glibc we compile and link against.
LL_DYNAMIC_LINKER=${pkgs.glibc}/lib/ld-linux-x86-64.so.2

# Flags for AMD dependencies.
LL_AMD_INCLUDES=${pkgs.lib.concatStringsSep ":" [
  "-isystem${pkgs.libdrm.dev}/include"
  "-isystem${pkgs.libdrm.dev}/include/libdrm"
  "-isystem${pkgs.elfutils.dev}/include"
  "-isystem${pkgs.numactl.dev}/include"
  "-isystem${pkgs.libglvnd.dev}/include"
  "-isystem${pkgs.xorg.libX11.dev}/include"
  "-isystem${pkgs.xorg.xorgproto}/include"
]}

LL_AMD_LIBRARIES=${pkgs.lib.concatStringsSep ":" [
  "-L${pkgs.libdrm}/lib"
  "-L${pkgs.numactl}/lib"
  "-L${pkgs.libglvnd}/lib"
  "-L${pkgs.elfutils.out}/lib"
  "-L${pkgs.libglvnd}/lib"
  "-L${pkgs.xorg.libX11}/lib"
]}

LL_AMD_RPATHS=${(pkgs.lib.concatStringsSep ":" [
  "-rpath=${pkgs.libdrm}/lib"
  "-rpath=${pkgs.numactl}/lib"
  "-rpath=${pkgs.libglvnd}/lib"
  "-rpath=${pkgs.elfutils.out}/lib"
  "-rpath=${pkgs.libglvnd}/lib"
  "-rpath=${pkgs.xorg.libX11}/lib"
])}
${pkgs.lib.strings.optionalString cudaSupport ''

# Flags for CUDA dependencies.
LL_CUDA_TOOLKIT=${cudaPackages.cudatoolkit}
LL_CUDA_RUNTIME=${cudaPackages.cudatoolkit.lib}
LL_CUDA_DRIVER=${pkgsUnfree.linuxPackages_6_4.nvidia_x11}
''}
# Only used by rules_cc
BAZEL_CXXOPTS=${pkgs.lib.concatStringsSep ":" [
  "-std=c++17"
  "-O3"
  "-nostdinc++"
  "-nostdlib++"
  "-isystem${llvmPackages.libcxx.dev}/include/c++/v1"
  "-isystem${llvmPackages.libcxxabi.dev}/include/c++/v1"
]}

# TODO: This somehow works without explicitly adding glibc to the library search
#       path. That shouldn't be the case. Maybe it's the clang wrapper, but
#       apparently that doesn't add the rpath. Find a better solution.
BAZEL_LINKOPTS=${pkgs.lib.concatStringsSep ":" [
  "-L${llvmPackages.libcxx}/lib"
  "-L${llvmPackages.libcxxabi}/lib"
  "-lc++"
  ("-Wl," +
  "-rpath,${llvmPackages.libcxx}/lib," +
  "-rpath,${llvmPackages.libcxxabi}/lib," +
  "-rpath,${pkgs.glibc}/lib"
  )
]}

if [[
    "$1" == "build" ||
    "$1" == "coverage" ||
    "$1" == "run" ||
    "$1" == "test"
]]; then
    ${bazel}/bin/bazel $1 \
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
    ${bazel}/bin/bazel $@
fi'';
}
