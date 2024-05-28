{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types;

  inherit (pkgs) runCommand writeText git;

  processedActionEnvs = map (x: "build --@rules_ll//ll:" + x) config.llEnv;

  configFile = runCommand ".bazelrc.ll" { } ''
    printf '# These flags are dynamically generated by rules_ll.
    #
    # Add try-import %%workspace%%/.bazelrc.ll to your .bazelrc to
    # include these flags when running Bazel in a nix environment.

    ${lib.concatLines processedActionEnvs}' >$out
  '';
in
{
  options = {
    installationScript = mkOption {
      type = types.str;
      description = lib.mkDoc ''
        A bash snippet which creates a .bazelrc.ll file in the repository.
      '';
    };
    llEnv = mkOption {
      type = types.listOf types.str;
      description = lib.mdDoc ''
        Environment variables for `--@rules_ll//ll:*` settings.

        For instance:

        ```nix
        llEnv = [
          "LL_CFLAGS=-I''${openssl.dev}/include"
        ]
        ```

        results in the following line in `.bazelrc.ll`:

        ```bash
        build --@rules_ll//ll:LL_CFLAGS=-I''${openssl.dev}/include
        ```

        Supported values are:

        - `LL_CFLAGS`
        - `LL_LDLAGS`
        - `LL_DYNAMIC_LINKER`
        - `LL_AMD_INCLUDES`
        - `LL_AMD_LIBRARIES`
        - `LL_CUDA_TOOLKIT`
        - `LL_CUDA_DRIVER`

        Attempting to set any other value will result in Bazel errors.
      '';
      default = { };
    };
  };

  config = {
    installationScript = ''
      if ! type -t git >/dev/null; then
        # In pure shells
        echo 1>&2 "WARNING: rules_ll: git command not found; skipping installation."
      elif ! ${git}/bin/git rev-parse --git-dir &> /dev/null; then
        echo 1>&2 "WARNING: rules_ll: .git not found; skipping installation."
      else
        GIT_WC=`${git}/bin/git rev-parse --show-toplevel`

        # These update procedures compare before they write, to avoid
        # filesystem churn. This improves performance with watch tools like
        # lorri and prevents installation loops by lorri.

        if ! readlink "''${GIT_WC}/.bazelrc.ll" >/dev/null \
          || [[ $(readlink "''${GIT_WC}/.bazelrc.ll") != ${configFile} ]]; then
          echo 1>&2 "rules_ll: updating $PWD repository"
          [ -L .bazelrc.ll ] && unlink .bazelrc.ll

          if [ -e "''${GIT_WC}/.bazelrc.ll" ]; then
            echo 1>&2 "rules_ll: WARNING: Refusing to install because of pre-existing .bazelrc.ll"
            echo 1>&2 "  Remove the .bazelrc.ll file and add .bazelrc.ll to .gitignore."
          else
            ln -fs ${configFile} "''${GIT_WC}/.bazelrc.ll"
          fi
        fi
      fi
    '';
  };
}
