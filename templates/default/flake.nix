{
  description = "your_project";

  nixConfig = {
    bash-prompt-prefix = "(rules_ll) ";
    bash-prompt = ''\[\033]0;\u@\h:\w\007\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\]'';
    bash-prompt-suffix = " ";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    rules_ll = {
      url = "github:eomii/rules_ll/20230411.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , pre-commit-hooks-nix
    , rules_ll
    , ...
    } @ inputs:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
    ]
      (system:
      let
        pkgs = import nixpkgs { inherit system; };
        hooks = import ./pre-commit-hooks.nix { inherit pkgs; };
        llShell = rules_ll.lib.${system}.llShell;
      in
      {
        checks = {
          pre-commit-check = pre-commit-hooks-nix.lib.${system}.run {
            src = ./.;
            inherit hooks;
          };
        };

        devShells = {
          default = llShell {
            # Set to true for NVPTX support, make sure to read the CUDA license.
            unfree = false;
            packages = [ ];
            # See https://ll.eomii.org/guides/external_dependencies/#example for
            # external dependencies.
            env = { };
            inherit hooks;
          };
        };
      });
}
