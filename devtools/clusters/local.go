package clusters

import (
	"bytes"
	"errors"
	"fmt"
	"log"
	"os"
	"path"
	"text/template"

	"sigs.k8s.io/kind/pkg/cluster"
)

var errKind = errors.New("kind error")

type LocalVolumePaths struct {
	Home       string
	Cache      string
	NixCache   string
	BazelCache string
}

func CreateLocalVolumes() (LocalVolumePaths, error) {
	log.Println("Preparing local directories for rules_ll caches")

	dirname, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}

	eomiidir := path.Join(dirname, ".eomii")
	cachedir := path.Join(eomiidir, "cache")
	nixcache := path.Join(cachedir, "ll-nix")
	bazelcache := path.Join(cachedir, "ll-bazel")

	for _, dir := range []string{eomiidir, cachedir, nixcache, bazelcache} {
		_, err = os.Stat(dir)

		if err != nil {
			if os.IsNotExist(err) {
				log.Printf("Creating directory: %s", dir)

				if err := os.Mkdir(dir, os.ModePerm); err != nil {
					log.Println("Couldn't create directory. Aborting.")
					log.Fatal(err)
				}
			} else {
				log.Println(
					"Something unexpected happened. Please raise an issue.",
				)
				log.Fatal(err)
			}
		}

		if !os.IsNotExist(err) {
			log.Printf("Directory already exists: %s", dir)
		}
	}

	return LocalVolumePaths{
		eomiidir,
		cachedir,
		nixcache,
		bazelcache,
	}, nil
}

func CreateLocalCluster(provider *cluster.Provider) error {
	localVolumePaths, err := CreateLocalVolumes()
	if err != nil {
		log.Println("Failed to set up local directories.")
		log.Fatal(err)
	}

	log.Printf("Creating kind cluster.")

	kindConfigTemplate, err := template.New("kind-config.yaml").Parse(`
---
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  extraMounts:
    - hostPath: {{ .NixCache }}
      containerPath: /nix-cache
    - hostPath: {{ .BazelCache }}
      containerPath: /bazel-cache
- role: worker
  extraMounts:
    - hostPath: {{ .NixCache }}
      containerPath: /nix-cache
    - hostPath: {{ .BazelCache }}
      containerPath: /bazel-cache
networking:
  disableDefaultCNI: true
  kubeProxyMode: none
`)
	if err != nil {
		log.Println("Failed to create template")
		log.Fatal(err)
	}

	var kindConfig bytes.Buffer
	if err = kindConfigTemplate.Execute(
		&kindConfig,
		localVolumePaths,
	); err != nil {
		log.Println("Failed to instantiate template")
		log.Fatal(err)
	}

	log.Println("Instantiating Kind Cluster with the following config:")
	log.Print(kindConfig.String())

	if err = provider.Create(
		"kind",
		cluster.CreateWithRawConfig(kindConfig.Bytes()),
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
