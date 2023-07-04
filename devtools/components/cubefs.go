package components

import (
	"fmt"
	"path"

	corev1 "github.com/pulumi/pulumi-kubernetes/sdk/v3/go/kubernetes/core/v1"
	helmv3 "github.com/pulumi/pulumi-kubernetes/sdk/v3/go/kubernetes/helm/v3"
	metav1 "github.com/pulumi/pulumi-kubernetes/sdk/v3/go/kubernetes/meta/v1"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

type CubeFS struct {
	Version   string
	ChartDir  string
	MountPath string
}

func (component *CubeFS) Install(
	ctx *pulumi.Context,
	name string,
) ([]pulumi.Resource, error) {
	cubefs, err := helmv3.NewChart(ctx, name, helmv3.ChartArgs{
		Path: pulumi.String(
			path.Join(component.ChartDir, "cubefs"),
		),
		Values: pulumi.Map{
			"component": pulumi.Map{
				"client":  pulumi.Bool(false),
				"csi":     pulumi.Bool(true),
				"monitor": pulumi.Bool(false),
				"ingress": pulumi.Bool(false),
			},
			"datanode": pulumi.Map{
				"disks": pulumi.StringArray{
					pulumi.String(
						fmt.Sprintf("%s:21474836480", component.MountPath),
					),
				},
			},
		},
	})
	if err != nil {
		return nil, fmt.Errorf("%w: %w", errPulumi, err)
	}

	pvc, err := corev1.NewPersistentVolumeClaim(
		ctx,
		fmt.Sprintf("%s-pvc", name),
		&corev1.PersistentVolumeClaimArgs{
			Metadata: &metav1.ObjectMetaArgs{
				Name: pulumi.String(fmt.Sprintf("%s-pvc", name)),
			},
			Spec: &corev1.PersistentVolumeClaimSpecArgs{
				StorageClassName: pulumi.String("cfs-sc"),
				AccessModes: pulumi.StringArray{
					pulumi.String("ReadWriteOnce"),
				},
				Resources: &corev1.ResourceRequirementsArgs{
					Requests: pulumi.StringMap{
						"storage": pulumi.String("5Gi"),
					},
				},
			},
		},
	)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", errPulumi, err)
	}

	return []pulumi.Resource{cubefs, pvc}, nil
}
