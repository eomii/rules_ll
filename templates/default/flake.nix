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
    rules_ll.url = "github:eomii/rules_ll/20230218.0";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , rules_ll
    , ...
    } @ inputs:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
    ]
      (system:
      let
        pkgs = import nixpkgs { inherit system; };
        llShell = rules_ll.lib.${system}.llShell;
      in
      {
        devShells = {
          default = llShell {
            # Set to true for NVPTX support, make sure to read the CUDA license.
            unfree = false;
            packages = [ ];
            # See https://ll.eomii.org/guides/external_dependencies/#example for
            # external dependencies.
            env = { };
          };
        };
      });
}
