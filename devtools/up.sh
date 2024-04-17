#!/usr/bin/env bash

set -xeuo pipefail

# native up

kubectl wait --for=condition=Programmed --timeout=60s gateway eventlistener

EVENTLISTENER=$(kubectl get gtw eventlistener -o=jsonpath='{.status.addresses[0].value}')

# Note: Keep this in sync with the commit in `ll/init.bzl`,
NATIVELINK_COMMIT=60f712bcddd5c2cd3d3bdd537c4cc136fe6497c7

curl -v \
    -H 'Content-Type: application/json' \
    -d '{
        "flakeOutput": "github:TraceMachina/nativelink/'"${NATIVELINK_COMMIT}"'#image"
    }' \
    http://"${EVENTLISTENER}":8080

curl -v \
    -H 'Content-Type: application/json' \
    -d '{
        "flakeOutput": "github:TraceMachina/nativelink/'"${NATIVELINK_COMMIT}"'#nativelink-worker-lre-cc"
    }' \
    http://"${EVENTLISTENER}":8080

until kubectl get pipelinerun \
        -l tekton.dev/pipeline=rebuild-nativelink | grep -q 'NAME'; do
    echo "Waiting for PipelineRuns to start..."
    sleep 0.1
done

kubectl wait \
    --for=condition=Succeeded \
    --timeout=30m \
    pipelinerun \
        -l tekton.dev/pipeline=rebuild-nativelink

KUSTOMIZE_DIR=$(git rev-parse --show-toplevel)/devtools
cat <<EOF > "$KUSTOMIZE_DIR"/kustomization.yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
bases:

resources:
  - https://github.com/TraceMachina/nativelink//deployment-examples/kubernetes/base
  - https://raw.githubusercontent.com/TraceMachina/nativelink/main/deployment-examples/kubernetes/worker-lre-cc.yaml
EOF


cd "$KUSTOMIZE_DIR" && kustomize edit set image \
    nativelink=localhost:5001/nativelink:"$(nix eval\
        github:TraceMachina/nativelink/${NATIVELINK_COMMIT}#image.imageTag --raw)" \
    nativelink-worker-lre-cc=localhost:5001/nativelink-worker-lre-cc:"$(nix eval\
        github:TraceMachina/nativelink/${NATIVELINK_COMMIT}#nativelink-worker-lre-cc.imageTag --raw)"

kubectl apply -k "$KUSTOMIZE_DIR"

kubectl rollout status deploy/nativelink-cas
kubectl rollout status deploy/nativelink-scheduler
kubectl rollout status deploy/nativelink-worker-lre-cc
