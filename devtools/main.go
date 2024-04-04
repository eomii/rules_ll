package main

import (
	"context"
	"log"
	"os"

	"github.com/eomii/rules_ll/devtools/clusters"
	"github.com/eomii/rules_ll/devtools/components"
	"github.com/pulumi/pulumi/sdk/v3/go/auto"
	"github.com/pulumi/pulumi/sdk/v3/go/auto/optup"
	"github.com/pulumi/pulumi/sdk/v3/go/common/tokens"
	"github.com/pulumi/pulumi/sdk/v3/go/common/workspace"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"sigs.k8s.io/kind/pkg/cluster"
	"sigs.k8s.io/kind/pkg/cmd"
)

func genericErrorCheck(err error) {
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}
}

func program(ctx *pulumi.Context) error {
	components.Check(components.AddComponent(
		ctx,
		"cilium",
		&components.Cilium{Version: "1.14.0-snapshot.2"},
	))
	components.Check(components.AddComponent(
		ctx,
		"zot",
		&components.Zot{Version: "0.1.53"},
	))
	components.Check(components.AddComponent(
		ctx,
		"tekton-pipelines",
		&components.TektonPipelines{Version: "0.47.0"},
	))
	components.Check(components.AddComponent(
		ctx,
		"tekton-triggers",
		&components.TektonTriggers{Version: "0.24.0"},
	))
	components.Check(components.AddComponent(
		ctx,
		"tekton-dashboard",
		&components.TektonDashboard{Version: "0.35.0"},
	))
	components.Check(components.AddComponent(
		ctx,
		"cubefs",
		// This is known to be vulnerable. For our use cases nothing dramatic,
		// but we should update as soon as an updated version is available.
		&components.CubeFS{
			Version:  "3.2.0",
			ChartDir: clusters.CubeFSHelmRepo(clusters.EomiiDir()),
			MountPath: clusters.CreateLocalDiskDirs(
				clusters.EomiiDir(),
			).MountPath,
		},
	))

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
		genericErrorCheck(clusters.CreateLocalCluster(kindProvider))
	}

	if argsWithoutProg[0] == "down" {
		genericErrorCheck(clusters.DeleteLocalCluster(kindProvider))
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
