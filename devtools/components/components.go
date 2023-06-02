package components

import (
	"errors"
	"fmt"
	"log"
	"os"

	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

var (
	errPulumi    = errors.New("pulumi error")
	errComponent = errors.New("component error")
)

func Check(_ []pulumi.Resource, err error) {
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}
}

type Component interface {
	Install(ctx *pulumi.Context, name string) ([]pulumi.Resource, error)
}

func AddComponent[C Component](
	ctx *pulumi.Context,
	name string,
	component C,
) ([]pulumi.Resource, error) {
	resources, err := component.Install(ctx, name)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", errComponent, err)
	}

	return resources, nil
}
