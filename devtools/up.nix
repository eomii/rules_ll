{ lib
, curl
, fluxcd
, kubectl
, kustomize
, native
, nix
, writeShellScriptBin
, ...
}:

let
  inherit (lib.meta) getExe;

  # The specific commit to use
  nativelinkCommit = "b1df876fd64d60d5d1b6cb15a50e934923ab82bf";

  # Base URL for GitHub access
  githubBaseUrl = "github:TraceMachina/nativelink/";

in

writeShellScriptBin "up" ''
  set -xeuo pipefail

  # Start the native service
  ${native}/bin/native up

  # Allow an additional grace period for potential routes to set themselves up.
  # TODO(aaronmondal): Find a better solution.
  sleep 10

  # Wait for the gateway to be ready
  ${getExe kubectl} apply -k \
    https://github.com/TraceMachina/nativelink//deploy/kubernetes-example?ref=${nativelinkCommit}

  # Wait for Tekton
  ${getExe fluxcd} reconcile kustomization -n default \
    --timeout=15m \
    nativelink-tekton-resources

  # Wait for Flux Alerts
  ${getExe fluxcd} reconcile kustomization -n default \
      --timeout=15m \
      nativelink-alert-core && \
    ${getExe fluxcd} reconcile kustomization -n default \
      --timeout=15m \
      nativelink-alert-worker-init && \
    ${getExe fluxcd} reconcile kustomization -n default \
      --timeout=15m \
      nativelink-alert-lre-cc

  ${getExe kubectl} apply -f - << 'EOF'
  apiVersion: source.toolkit.fluxcd.io/v1
  kind: GitRepository
  metadata:
    name: dummy-repository
    namespace: default
  spec:
    interval: 2m
    url: https://github.com/TraceMachina/nativelink
    ref:
      branch: main
  EOF

  # Wait for PipelineRuns
  until pr=$(${getExe kubectl} get pipelinerun -o name | \
             grep rebuild-nativelink-run-); do
    echo "Waiting for pipeline to be created..."
    sleep 1
  done

  echo "Found pipeline: $pr"
  ${getExe kubectl} wait --for=create $pr

  # Wait for the pipeline to succeed
  ${getExe kubectl} wait \
    --for=condition=Succeeded \
    --timeout=45m \
    pipelinerun \
    -l tekton.dev/pipeline=rebuild-nativelink

  # Wait for NativeLink Kustomization
  ${getExe fluxcd} reconcile kustomization -n default \
    --timeout=15m \
    nativelink-core

  # Wait for worker Kustomization
  ${getExe fluxcd} reconcile kustomization -n default \
    --timeout=15m \
    nativelink-lre-cc

  # Monitor the deployment rollout
  ${getExe kubectl} rollout status deploy/nativelink
  ${getExe kubectl} rollout status deploy/nativelink-worker-lre-cc

  echo "nativelink_ip=$(${getExe kubectl} get gtw nativelink-gateway -o=jsonpath='{.status.addresses[0].value}')"
''
