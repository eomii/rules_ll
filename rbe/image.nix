{ pkgs
, llvmPackages
, bazel
, env ? (import ../modules/rules_ll-action-env.nix { inherit pkgs; })
, tag
}:

pkgs.dockerTools.buildLayeredImage {
  inherit tag;
  name = "rules_ll";

  contents = [
    bazel

    # Minimal user setup. Required by Bazel.
    pkgs.fakeNss

    # Required for communication with trusted sources.
    pkgs.cacert

    # Tools that we would usually forward from the host.
    pkgs.bash
    pkgs.coreutils

    # We need these tools to generate the RBE autoconfiguration.
    pkgs.glibc.bin
    pkgs.findutils
    pkgs.gnutar
  ];

  extraCommands = ''
    mkdir -m 0777 tmp
  '';

  config = {
    # Cmd = [ "ls" "/nix/store" ];
    WorkingDir = "/home/bazelbuild";
    Env = [
      # The only program ever intended to actually open a shell in the container
      # is the rbe_configs_gen tool. This tool shouldn't see /bin or /sbin since
      # that would cause it to break the hermeticity of the generated C++
      # toolchains. Instead we manually set all C++ tools here so that they are
      # all referenced via their /nix/store path.
      ("PATH=" + (pkgs.lib.strings.concatStringsSep ":" [
        "${llvmPackages.clang}/bin"
        "${llvmPackages.llvm}/bin"
        "${pkgs.coreutils}/bin"
        "${pkgs.findutils}/bin"
        "${pkgs.gnutar}/bin"
      ]))
      "JAVA_HOME=${pkgs.jdk17_headless}/lib/openjdk"

      # The rbe_configs_gen seems to only care about the CC variable, but not
      # about other make variables like LD, AR or NM. This is unfortunate as it
      # forces us to rely on autodetection via the PATH.
      "CC=${llvmPackages.clang}/bin/clang"
    ] ++ env;
  };
}
