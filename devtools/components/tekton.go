package components

import (
	"fmt"

	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/yaml"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

type TektonPipelines struct {
	Version string
}

func (component *TektonPipelines) Install(
	ctx *pulumi.Context,
	name string,
) ([]pulumi.Resource, error) {
	tektonPipelines, err := yaml.NewConfigFile(ctx, name, &yaml.ConfigFileArgs{
		File: fmt.Sprintf(
			"https://storage.googleapis.com/tekton-releases/pipeline/previous/v%s/release.yaml",
			component.Version,
		),
	})
	if err != nil {
		return nil, fmt.Errorf("%w: %w", errPulumi, err)
	}

	return []pulumi.Resource{tektonPipelines}, nil
}

type TektonTriggers struct {
	Version string
}

func (component *TektonTriggers) Install(
	ctx *pulumi.Context,
	name string,
) ([]pulumi.Resource, error) {
	tektonTriggers, err := yaml.NewConfigFile(ctx, name, &yaml.ConfigFileArgs{
		File: fmt.Sprintf(
			"https://storage.googleapis.com/tekton-releases/pipeline/triggers/previous/v%s/release.yaml",
			component.Version,
		),
	})
	if err != nil {
		return nil, fmt.Errorf("%w: %w", errPulumi, err)
	}

	return []pulumi.Resource{tektonTriggers}, nil
}

type TektonDashboard struct {
	Version string
}

func (component *TektonDashboard) Install(
	ctx *pulumi.Context,
	name string,
) ([]pulumi.Resource, error) {
	tektonDashboard, err := yaml.NewConfigFile(ctx, name, &yaml.ConfigFileArgs{
		File: fmt.Sprintf(
			"https://storage.googleapis.com/tekton-releases/dashboard/previous/v%s/release.yaml",
			component.Version,
		),
	})
	if err != nil {
		return nil, fmt.Errorf("%w: %w", errPulumi, err)
	}

	return []pulumi.Resource{tektonDashboard}, nil
}
