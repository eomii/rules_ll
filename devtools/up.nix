{ pkgs, native, ... }:

let
  # Packages needed for the script
  kubectl = pkgs.kubectl;
  curl = pkgs.curl;
  git = pkgs.git;
  kustomize = pkgs.kustomize;
  nix = pkgs.nix;

  # The specific commit to use
  nativelinkCommit = "8a632953b86395088e4ab8c1e160a650739549b7";

  # Base URL for GitHub access
  githubBaseUrl = "github:TraceMachina/nativelink/";

in

pkgs.writeShellScriptBin "up" ''
  set -xeuo pipefail

  # Start the native service
  ${native}/bin/native up

  # Wait for the gateway to be ready
  ${kubectl}/bin/kubectl wait --for=condition=Programmed --timeout=60s gateway eventlistener

  # Allow an additional grace period for potential routes to set themselves up.
  # TODO(aaronmondal): Find a better solution.
  sleep 10

  # Retrieve the event listener address
  EVENTLISTENER=''$(${kubectl}/bin/kubectl get gtw eventlistener -o=jsonpath='{.status.addresses[0].value}')

  # POST requests to the event listener
  ${curl}/bin/curl -v \
    -H 'Content-Type: application/json' \
    -d '{"flakeOutput": "${githubBaseUrl}${nativelinkCommit}#image"}' \
    http://"''${EVENTLISTENER}":8080

  ${curl}/bin/curl -v \
    -H 'Content-Type: application/json' \
    -d '{"flakeOutput": "${githubBaseUrl}${nativelinkCommit}#nativelink-worker-lre-cc"}' \
    http://"''${EVENTLISTENER}":8080

  # Wait for PipelineRuns to start
  until ${kubectl}/bin/kubectl get pipelinerun \
      -l tekton.dev/pipeline=rebuild-nativelink | grep -q 'NAME'; do
    echo "Waiting for PipelineRuns to start..."
    sleep 0.1
  done

  # Wait for the pipeline to succeed
  ${kubectl}/bin/kubectl wait \
    --for=condition=Succeeded \
    --timeout=30m \
    pipelinerun \
        -l tekton.dev/pipeline=rebuild-nativelink

  # Define kustomize directory and setup
  KUSTOMIZE_DIR=''$(${git}/bin/git rev-parse --show-toplevel)

  cat <<EOF > "''${KUSTOMIZE_DIR}"/kustomization.yaml
  ---
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization
  bases:
  resources:
    - https://github.com/TraceMachina/nativelink//deployment-examples/kubernetes/base
    - https://raw.githubusercontent.com/TraceMachina/nativelink/main/deployment-examples/kubernetes/worker-lre-cc.yaml
  EOF

  # Use kustomize to set images
  cd "''${KUSTOMIZE_DIR}" && ${kustomize}/bin/kustomize edit set image \
    nativelink=localhost:5001/nativelink:"''$(${nix}/bin/nix eval ${githubBaseUrl}${nativelinkCommit}#image.imageTag --raw)" \
    nativelink-worker-lre-cc=localhost:5001/nativelink-worker-lre-cc:"''$(${nix}/bin/nix eval ${githubBaseUrl}${nativelinkCommit}#nativelink-worker-lre-cc.imageTag --raw)"

  # Apply the configuration
  ${kubectl}/bin/kubectl apply -k "''${KUSTOMIZE_DIR}"

  # Monitor the deployment rollout
  ${kubectl}/bin/kubectl rollout status deploy/nativelink-cas
  ${kubectl}/bin/kubectl rollout status deploy/nativelink-scheduler
  ${kubectl}/bin/kubectl rollout status deploy/nativelink-worker-lre-cc
''
