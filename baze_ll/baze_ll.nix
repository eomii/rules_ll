{ pkgs }:

# We use this customized variant of Bazel because some subtools in the regular
# variants have issues finding dynamic libstdc++ during runtime. We don't expect
# this to get fixed anytime soon, so we build a customized variant that
# statically links libc++ into the bazel sub-executables. Note that this doesn't
# make Bazel independent of libstdc++ as we still need it for openjdk.

# Overriding this version of Bazel to link against musl libc is possible but
# quite hacky and incredibly compile-time intensive. Since we need glibc anyways
# for heterogeneous targets it's currently not worth the extra effort to also
# support musl-based containers.

# TODO: Upstream fixes to nixpkgs so that we can support musl properly.

let
  # As of Bazel 6.1.1 the abseil dependency in upb is so ancient that we can't
  # build it with clang 15. We can still use libcxx 15 though.
  LLVMOverride = {
    stdenv = pkgs.overrideCC pkgs.llvmPackages_14.libcxxStdenv
      (pkgs.wrapCCWith {
        cc = pkgs.llvmPackages_14.clang-unwrapped;
        bintools = pkgs.wrapBintoolsWith {
          bintools = pkgs.llvmPackages_14.bintools-unwrapped;
        };
      });
  };

  # These libraries are statically linked into the final Bazel executable in
  # place of libstdc++.
  # TODO: This current implementation seems to work but still links libgcc_s
  #       which shouldn't be required.
  libunwindStatic = pkgs.llvmPackages_15.libunwind.override {
    enableShared = false;
  };
  libcxxabiStatic = pkgs.llvmPackages_15.libcxxabi.override {
    libunwind = libunwindStatic;
    enableShared = false;
  };
  libcxxStatic = pkgs.llvmPackages_15.libcxx.override {
    libcxxabi = libcxxabiStatic;
    enableShared = false;
  };
  compiler-rt = pkgs.llvmPackages_15.compiler-rt.override {
    libcxxabi = libcxxabiStatic;
  };

  LLVMOverrideCXX = LLVMOverride // { libcxx = libcxxStatic; };

  # Disable (most) transitive dependencies on libstdc++ (except for openjdk).
  coreutils = pkgs.coreutils.override { gmpSupport = false; };
  findutils = pkgs.findutils.override { inherit coreutils; };

  env = {
    NIX_CFLAGS_COMPILE = pkgs.lib.strings.concatStringsSep " " [
      "-O3"
      "-nostdinc++"
      "-isystem${libcxxStatic.dev}/include/c++/v1"
      "-isystem${libcxxabiStatic.dev}/include/c++/v1"
      "-resource-dir=${pkgs.llvmPackages_14.clang}/resource-root"
    ];
    NIX_LDFLAGS = pkgs.lib.strings.concatStringsSep " " [
      # TODO: The current llvm stdenv doesn't use lld properly.
      #       Test the flags below if that changes.
      # "-fuse-ld=lld"
      # "--stdlib=libc++"
      # "-rtlib=compiler-rt"
      "-unwindlib=libunwind"
      "-L${libcxxStatic}/lib"
      "-lc++"
      "-L${libcxxabiStatic}/lib"
      "-lc++abi"
      "-L${compiler-rt}/lib/linux"
      "-L${libunwindStatic}/lib"
    ];
  };
in
(pkgs.bazel_6.overrideAttrs (final: prev: {
  inherit env;
})).override (LLVMOverrideCXX // {
  inherit coreutils findutils;

  # TODO: This is the default, but we need to change it ASAP since this is the
  # only remaining edge to libstdc++. It's surprisingly tricky to build the jdk
  # with an llvm toolchain, but it's surely possible.
  buildJdk = pkgs.jdk11_headless;
})
