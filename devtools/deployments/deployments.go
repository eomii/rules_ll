package deployments

import (
	"errors"
	"fmt"

	"github.com/pulumi/pulumi-kubernetes/sdk/v3/go/kubernetes/helm/v3"
	"github.com/pulumi/pulumi-kubernetes/sdk/v3/go/kubernetes/yaml"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

var errPulumi = errors.New("pulumi error")

//nolint:nolintlint,typecheck // The helm type is broken.
func DeployCilium(ctx *pulumi.Context) error {
	chartArgs := helm.ChartArgs{
		Chart:     pulumi.String("cilium"),
		Version:   pulumi.String("1.14.0-snapshot.2"),
		Namespace: pulumi.String("kube-system"),
		FetchArgs: helm.FetchArgs{
			Repo: pulumi.String("https://helm.cilium.io/"),
		},
		Values: pulumi.Map{
			// Name of the `control-plane` node in `kubectl get nodes`.
			"k8sServiceHost": pulumi.String("kind-control-plane"),

			// Forwarded port in `docker ps` for the control plane.
			"k8sServicePort": pulumi.String("6443"),

			// Required for proper Cilium operation.
			"kubeProxyReplacement": pulumi.String("strict"),

			// IPAM config subnets from `docker network inspect kind`.
			"ipv4NativeRoutingCIDR": pulumi.String("172.20.0.0/16"),
			"ipv6NativeRoutingCIDR": pulumi.String("fc00:f853:ccd:e793::/64"),

			// Faster masquerading.
			"bpf": pulumi.Map{
				"masquerade": pulumi.Bool(true),
				"tproxy":     pulumi.Bool(true),
			},

			"ipam": pulumi.Map{
				"mode": pulumi.String("kubernetes"),
				"operator": pulumi.Map{
					// Default values for kind.
					"clusterPoolIPv4PodCIDRList": pulumi.String(
						"10.244.0.0/16",
					),
					"clusterPoolIPv6PodCIDRList": pulumi.String(
						"fd00:10:244::/56",
					),
				},
			},

			"image": pulumi.Map{
				"pullPolicy": pulumi.String("IfNotPresent"),
			},
			"hubble": pulumi.Map{
				"relay": pulumi.Map{"enabled": pulumi.Bool(true)},
				"ui":    pulumi.Map{"enabled": pulumi.Bool(true)},
			},

			// This causes issues. Find out why and enable it.
			// "autoDirectNodeRoutes": pulumi.Bool(true),
			// "tunnel":               pulumi.String("disabled"),
		},
	}
	if _, err := helm.NewChart(ctx, "cilium", chartArgs); err != nil {
		return fmt.Errorf("%w: %w", errPulumi, err)
	}

	return nil
}

//nolint:nolintlint,typecheck // The helm type is broken.
func DeployZot(ctx *pulumi.Context) error {
	chartArgs := helm.ChartArgs{
		Chart:     pulumi.String("zot"),
		Version:   pulumi.String("0.1.21"),
		Namespace: pulumi.String("kube-system"),
		FetchArgs: helm.FetchArgs{
			Repo: pulumi.String("https://zotregistry.io/helm-charts"),
		},
	}

	if _, err := helm.NewChart(ctx, "zot", chartArgs); err != nil {
		return fmt.Errorf("%w: %w", errPulumi, err)
	}

	return nil
}

func DeployTektonPipelines(ctx *pulumi.Context) error {
	fileArgs := &yaml.ConfigFileArgs{
		File: "https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.47.0/release.yaml",
	}
	if _, err := yaml.NewConfigFile(ctx, "tekton-pipelines", fileArgs); err != nil {
		return fmt.Errorf("%w: %w", errPulumi, err)
	}

	return nil
}

func DeployTektonTriggers(ctx *pulumi.Context) error {
	fileArgs := &yaml.ConfigFileArgs{
		File: "https://storage.googleapis.com/tekton-releases/pipeline/triggers/previous/v0.24.0/release.yaml",
	}
	if _, err := yaml.NewConfigFile(ctx, "tekton-triggers", fileArgs); err != nil {
		return fmt.Errorf("%w: %w", errPulumi, err)
	}

	return nil
}

func DeployTektonDashboard(ctx *pulumi.Context) error {
	fileArgs := &yaml.ConfigFileArgs{
		File: "https://storage.googleapis.com/tekton-releases/dashboard/previous/v0.35.0/release-full.yaml",
	}
	if _, err := yaml.NewConfigFile(ctx, "tekton-dashboard", fileArgs); err != nil {
		return fmt.Errorf("%w: %w", errPulumi, err)
	}

	return nil
}
