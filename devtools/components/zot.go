package components

import (
	"fmt"

	"github.com/pulumi/pulumi-kubernetes/sdk/v3/go/kubernetes/helm/v3"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

type Zot struct {
	Version string
}

//
//nolint:nolintlint,typecheck // The helm type is broken.
func (component *Zot) Install(
	ctx *pulumi.Context,
	name string,
) ([]pulumi.Resource, error) {
	zot, err := helm.NewChart(ctx, name, helm.ChartArgs{
		Chart:     pulumi.String("zot"),
		Version:   pulumi.String(component.Version),
		Namespace: pulumi.String("kube-system"),
		FetchArgs: helm.FetchArgs{
			Repo: pulumi.String("https://zotregistry.io/helm-charts"),
		},
	},
	)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", errPulumi, err)
	}

	return []pulumi.Resource{zot}, nil
}
