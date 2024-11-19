{ pkgs, native, ... }:

let
  # Packages needed for the script
  kubectl = pkgs.kubectl;
  curl = pkgs.curl;
  git = pkgs.git;
  kustomize = pkgs.kustomize;
  nix = pkgs.nix;

  # The specific commit to use
  nativelinkCommit = "481226be52a84ad5a6b990cc48e9f97512d8ccd2";

  # Base URL for GitHub access
  githubBaseUrl = "github:TraceMachina/nativelink/";

in

pkgs.writeShellScriptBin "up" ''
  set -xeuo pipefail

  # Start the native service
  ${native}/bin/native up

  # Allow an additional grace period for potential routes to set themselves up.
  # TODO(aaronmondal): Find a better solution.
  sleep 10

  # Wait for the gateway to be ready
  ${kubectl}/bin/kubectl apply -k \
    https://github.com/TraceMachina/nativelink//deploy/kubernetes-example?ref=${nativelinkCommit}

  # Wait for PipelineRuns to start
  until ${kubectl}/bin/kubectl get pipelinerun \
      -l tekton.dev/pipeline=rebuild-nativelink | grep -q 'NAME'; do
    echo "Waiting for PipelineRuns to start..."
    sleep 1
  done

  # Wait for the pipeline to succeed
  ${kubectl}/bin/kubectl wait \
    --for=condition=Succeeded \
    --timeout=30m \
    pipelinerun \
        -l tekton.dev/pipeline=rebuild-nativelink

  # TODO(aaronmondal): Find a better solution.
  sleep 10

  # Monitor the deployment rollout
  ${kubectl}/bin/kubectl rollout status deploy/nativelink-cas
  ${kubectl}/bin/kubectl rollout status deploy/nativelink-scheduler
  ${kubectl}/bin/kubectl rollout status deploy/nativelink-worker-lre-cc
''
