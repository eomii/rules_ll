package components

import (
	"fmt"

	helmv3 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/helm/v3"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

type Cilium struct {
	Version string
}

func (component *Cilium) Install(
	ctx *pulumi.Context,
	name string,
) ([]pulumi.Resource, error) {
	cilium, err := helmv3.NewChart(ctx, name, helmv3.ChartArgs{
		Chart:     pulumi.String("cilium"),
		Version:   pulumi.String(component.Version),
		Namespace: pulumi.String("kube-system"),
		FetchArgs: helmv3.FetchArgs{
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

			"image": pulumi.Map{"pullPolicy": pulumi.String("IfNotPresent")},

			"hubble": pulumi.Map{
				"relay": pulumi.Map{"enabled": pulumi.Bool(true)},
				"ui":    pulumi.Map{"enabled": pulumi.Bool(true)},
			},

			// This causes issues. Find out why and enable it.
			// "autoDirectNodeRoutes": pulumi.Bool(true),
			// "tunnel":               pulumi.String("disabled"),
		},
	})
	if err != nil {
		return nil, fmt.Errorf("%w: %w", errPulumi, err)
	}

	return []pulumi.Resource{cilium}, nil
}
