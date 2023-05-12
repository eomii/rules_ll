package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"

	"github.com/pulumi/pulumi-kubernetes/sdk/v3/go/kubernetes/helm/v3"
	"github.com/pulumi/pulumi-kubernetes/sdk/v3/go/kubernetes/yaml"
	"github.com/pulumi/pulumi/sdk/v3/go/auto"
	"github.com/pulumi/pulumi/sdk/v3/go/auto/optup"
	"github.com/pulumi/pulumi/sdk/v3/go/common/tokens"
	"github.com/pulumi/pulumi/sdk/v3/go/common/workspace"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"sigs.k8s.io/kind/pkg/cluster"
	"sigs.k8s.io/kind/pkg/cmd"
)

var (
	errPulumi = errors.New("pulumi error")
	errKind   = errors.New("kind error")
)

func genericErrorCheck(err error) {
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}
}

//nolint:nolintlint,typecheck // The helm type is broken.
func deployCilium(ctx *pulumi.Context) error {
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
func deployZot(ctx *pulumi.Context) error {
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

func deployTektonPipelines(ctx *pulumi.Context) error {
	fileArgs := &yaml.ConfigFileArgs{
		File: "https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.47.0/release.yaml",
	}
	if _, err := yaml.NewConfigFile(ctx, "tekton-pipelines", fileArgs); err != nil {
		return fmt.Errorf("%w: %w", errPulumi, err)
	}

	return nil
}

func deployTektonTriggers(ctx *pulumi.Context) error {
	fileArgs := &yaml.ConfigFileArgs{
		File: "https://storage.googleapis.com/tekton-releases/pipeline/triggers/previous/v0.24.0/release.yaml",
	}
	if _, err := yaml.NewConfigFile(ctx, "tekton-triggers", fileArgs); err != nil {
		return fmt.Errorf("%w: %w", errPulumi, err)
	}

	return nil
}

func deployTektonDashboard(ctx *pulumi.Context) error {
	fileArgs := &yaml.ConfigFileArgs{
		File: "https://storage.googleapis.com/tekton-releases/dashboard/previous/v0.35.0/release-full.yaml",
	}
	if _, err := yaml.NewConfigFile(ctx, "tekton-dashboard", fileArgs); err != nil {
		return fmt.Errorf("%w: %w", errPulumi, err)
	}

	return nil
}

func program(ctx *pulumi.Context) error {
	if err := deployCilium(ctx); err != nil {
		return err
	}

	if err := deployZot(ctx); err != nil {
		return err
	}

	if err := deployTektonPipelines(ctx); err != nil {
		return err
	}

	if err := deployTektonTriggers(ctx); err != nil {
		return err
	}

	return deployTektonDashboard(ctx)
}

func createLocalCluster(provider *cluster.Provider) error {
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

func deleteLocalCluster(provider *cluster.Provider) error {
	log.Printf("Deleting cluster.")

	if err := provider.Delete("kind", ""); err != nil {
		return fmt.Errorf("%w: %w", errKind, err)
	}

	return nil
}

func main() {
	argsWithoutProg := os.Args[1:]
	if len(argsWithoutProg) != 1 {
		log.Printf(
			"Failed to interpret command. Please specify 'up' or 'down'.",
		)
		os.Exit(1)
	}

	// Kind cluster setup/teardown.
	kindProvider := cluster.NewProvider(
		cluster.ProviderWithLogger(cmd.NewLogger()),
	)
	if argsWithoutProg[0] == "up" {
		genericErrorCheck(createLocalCluster(kindProvider))
	}

	if argsWithoutProg[0] == "down" {
		genericErrorCheck(deleteLocalCluster(kindProvider))
		os.Exit(0)
	}

	// Pulumi cluster setup/refresh.
	ctx := context.Background()
	projectName := "rules_ll_cluster"
	stackName := "dev"

	project := auto.Project(workspace.Project{
		Name:    tokens.PackageName(projectName),
		Runtime: workspace.NewProjectRuntimeInfo("go", nil),
		Backend: &workspace.ProjectBackend{URL: "file://~/.pulumi"},
	})

	// Only use this for local development.
	envvars := auto.EnvVars(map[string]string{"PULUMI_CONFIG_PASSPHRASE": ""})

	stack, err := auto.UpsertStackInlineSource(
		ctx,
		stackName,
		projectName,
		program,
		project,
		envvars,
	)
	genericErrorCheck(err)
	log.Printf("Operating on stack %q\n", stackName)

	log.Println("Starting refresh")

	_, err = stack.Refresh(ctx)
	genericErrorCheck(err)

	log.Println("Refresh succeeded.")

	log.Println("Starting update")

	stdoutStreamer := optup.ProgressStreams(os.Stdout)
	_, err = stack.Up(ctx, stdoutStreamer)
	genericErrorCheck(err)

	log.Println("Cluster is running. Use `kubectl` to interact with it.")
}
