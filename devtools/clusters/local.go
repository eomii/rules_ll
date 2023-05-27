package clusters

import (
	"errors"
	"fmt"
	"log"

	"sigs.k8s.io/kind/pkg/cluster"
)

var errKind = errors.New("kind error")

func CreateLocalCluster(provider *cluster.Provider) error {
	log.Printf("Creating kind cluster.")

	if err := provider.Create(
		"kind",
		cluster.CreateWithRawConfig([]byte(`
---
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
networking:
  disableDefaultCNI: true
  kubeProxyMode: none
`),
		),
	); err != nil {
		return fmt.Errorf("%w: %w", errKind, err)
	}

	return nil
}

func DeleteLocalCluster(provider *cluster.Provider) error {
	log.Printf("Deleting cluster.")

	if err := provider.Delete("kind", ""); err != nil {
		return fmt.Errorf("%w: %w", errKind, err)
	}

	return nil
}
