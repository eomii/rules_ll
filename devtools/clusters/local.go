package clusters

import (
	"bytes"
	"errors"
	"fmt"
	"log"
	"os"
	"path"
	"text/template"

	"github.com/go-git/go-git/v5"
	"sigs.k8s.io/kind/pkg/cluster"
)

var errKind = errors.New("kind error")

type LocalDiskDirs struct {
	Disks     []string
	MountPath string
}

func createDirectory(absolutePath string) {
	_, err := os.Stat(absolutePath)
	if err != nil {
		if os.IsNotExist(err) {
			log.Printf("Creating directory: %s", absolutePath)

			if err := os.Mkdir(absolutePath, os.ModePerm); err != nil {
				log.Fatal("Couldn't create directory. Aborting.")
			}
		} else {
			log.Fatal(
				"Something unexpected happened. Please raise an issue.",
			)
		}
	}

	if !os.IsNotExist(err) {
		log.Printf("Directory already exists: %s", absolutePath)
	}
}

func CreateLocalDiskDirs(basedir string) LocalDiskDirs {
	log.Println("Preparing local disk directories for CubeFS deployment.")

	disks := []string{
		path.Join(basedir, "kind-worker-disk"),
		path.Join(basedir, "kind-worker2-disk"),
		path.Join(basedir, "kind-worker3-disk"),
	}

	for _, dir := range disks {
		createDirectory(dir)
	}

	return LocalDiskDirs{disks, "/data0"}
}

func EomiiDir() string {
	homedir, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}

	eomiidir := path.Join(homedir, ".eomii")
	createDirectory(eomiidir)

	return eomiidir
}

//nolint:nolintlint,typecheck  // The git type is broken.
func CubeFSHelmRepo(basedir string) string {
	cubefsdir := path.Join(basedir, "cubefs-helm")
	_, err := git.PlainClone(cubefsdir, false, &git.CloneOptions{
		URL:      "https://github.com/cubefs/cubefs-helm",
		Progress: os.Stdout,
	})

	if errors.Is(err, git.ErrRepositoryAlreadyExists) {
		log.Println("CubeFS repo already cloned previously.")

		return cubefsdir
	} else if err != nil {
		log.Fatal(err)
	}

	return cubefsdir
}

func CreateLocalKindConfig(localDiskDirs LocalDiskDirs) bytes.Buffer {
	kindConfigTemplate, err := template.New("kind-config.yaml").Parse(`
---
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  extraMounts:
    - hostPath: {{ index .Disks 0 }}
      containerPath: {{ .MountPath }}
  labels:
    component.cubefs.io/master: enabled
    component.cubefs.io/metanode: enabled
    component.cubefs.io/datanode: enabled
    component.cubefs.io/objectnode: enabled
    component.cubefs.io/csi: enabled
- role: worker
  extraMounts:
    - hostPath: {{ index .Disks 1 }}
      containerPath: {{ .MountPath }}
  labels:
    component.cubefs.io/master: enabled
    component.cubefs.io/metanode: enabled
    component.cubefs.io/datanode: enabled
- role: worker
  extraMounts:
    - hostPath: {{ index .Disks 2 }}
      containerPath: {{ .MountPath }}
  labels:
    component.cubefs.io/master: enabled
    component.cubefs.io/metanode: enabled
    component.cubefs.io/datanode: enabled
networking:
  disableDefaultCNI: true
  kubeProxyMode: none
`)
	if err != nil {
		log.Fatal(err)
	}

	var kindConfig bytes.Buffer
	if err = kindConfigTemplate.Execute(
		&kindConfig,
		localDiskDirs,
	); err != nil {
		log.Fatal(err)
	}

	return kindConfig
}

func CreateLocalCluster(provider *cluster.Provider) error {
	log.Printf("Setting up base directories.")

	localDiskDirs := CreateLocalDiskDirs(EomiiDir())

	log.Printf("Creating kind cluster.")

	kindConfig := CreateLocalKindConfig(localDiskDirs)

	log.Println("Instantiating Kind Cluster with the following config:")
	log.Print(kindConfig.String())

	if err := provider.Create(
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
