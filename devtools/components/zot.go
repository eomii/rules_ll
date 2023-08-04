package components

import (
	"fmt"

	helmv3 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/helm/v3"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

type Zot struct {
	Version string
}

func (component *Zot) Install(
	ctx *pulumi.Context,
	name string,
) ([]pulumi.Resource, error) {
	zot, err := helmv3.NewChart(ctx, name, helmv3.ChartArgs{
		Chart:     pulumi.String("zot"),
		Version:   pulumi.String(component.Version),
		Namespace: pulumi.String("kube-system"),
		FetchArgs: helmv3.FetchArgs{
			Repo: pulumi.String("https://zotregistry.io/helm-charts"),
		},
	},
	)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", errPulumi, err)
	}

	return []pulumi.Resource{zot}, nil
}
