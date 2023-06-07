package components

import (
	"fmt"

	corev1 "github.com/pulumi/pulumi-kubernetes/sdk/v3/go/kubernetes/core/v1"
	metav1 "github.com/pulumi/pulumi-kubernetes/sdk/v3/go/kubernetes/meta/v1"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

type LocalVolumes struct{}

const volumeAndClaim = 2

func (component *LocalVolumes) Install(
	ctx *pulumi.Context,
	name string,
) ([]pulumi.Resource, error) {
	volumes := []string{"nix-cache", "bazel-cache"}
	resources := make([]pulumi.Resource, 0, volumeAndClaim*len(volumes))

	for _, mode := range volumes {
		localPV, err := corev1.NewPersistentVolume(
			ctx,
			fmt.Sprintf("%s-%s", name, mode),
			&corev1.PersistentVolumeArgs{
				Metadata: &metav1.ObjectMetaArgs{
					Name: pulumi.String(mode),
				},
				Spec: &corev1.PersistentVolumeSpecArgs{
					StorageClassName: pulumi.String("standard"),
					AccessModes: pulumi.StringArray{
						pulumi.String("ReadWriteOnce"),
					},
					Capacity: pulumi.StringMap{
						"storage": pulumi.String("80Gi"),
					},
					HostPath: &corev1.HostPathVolumeSourceArgs{
						Path: pulumi.String(fmt.Sprintf("/%s", mode)),
					},
				},
			},
		)
		if err != nil {
			return nil, fmt.Errorf("%w: %w", errPulumi, err)
		}

		localPVC, err := corev1.NewPersistentVolumeClaim(
			ctx,
			fmt.Sprintf("%s-%s", name, mode),
			&corev1.PersistentVolumeClaimArgs{
				Metadata: &metav1.ObjectMetaArgs{
					Name: pulumi.String(mode),
				},
				Spec: &corev1.PersistentVolumeClaimSpecArgs{
					VolumeName: localPV.Metadata.Name().Elem(),
					AccessModes: pulumi.StringArray{
						pulumi.String("ReadWriteOnce"),
					},
					Resources: &corev1.ResourceRequirementsArgs{
						Requests: pulumi.StringMap{
							"storage": pulumi.String("40Gi"),
						},
					},
				},
			},
		)
		if err != nil {
			return nil, fmt.Errorf("%w: %w", errPulumi, err)
		}

		resources = append(resources, localPV, localPVC)
	}

	return resources, nil
}
