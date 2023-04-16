{ pkgs, wrappedBazel }:

let bazelToolchains = import ../rbe/default.nix { inherit pkgs; }; in

pkgs.writeShellScriptBin "rbe" ''
  # Make sure to only use this tool from the root directory of rules_ll.
  # You need a local docker registry running to regenerate the rbe
  # configuration:
  # docker run -d -p 5000:5000 --restart=always --name registry registry:2

  # Deliberately build the image manually and use "result" instead of
  # the derivation to prevent nix from building the image unless
  # explicitly asked to.

  nix build .#ci-image

  ${pkgs.skopeo}/bin/skopeo \
      --insecure-policy \
      copy \
      --dest-tls-verify=false \
      "docker-archive://$(realpath result)" \
      "docker://localhost:5000/rules_ll_remote"

  ${bazelToolchains}/bin/rbe_configs_gen \
      --toolchain_container=localhost:5000/rules_ll_remote \
      --exec_os=linux \
      --target_os=linux \
      --bazel_version=${wrappedBazel.version} \
      --output_src_root=$(pwd) \
      --output_config_path=rbe/default \
      --bazel_path=${wrappedBazel.baze_ll}/bin/bazel \
      --cpp_env_json=rbe/rbeconfig.json

  pre-commit run --all-files
''
