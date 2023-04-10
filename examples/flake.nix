{
  description = "rules_ll examples";

  nixConfig = {
    bash-prompt-prefix = "(rules_ll) ";
    bash-prompt = ''\[\033]0;\u@\h:\w\007\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\]'';
    bash-prompt-suffix = " ";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    # If you use this file as template, substitute the line below with this,
    # where `<version>` is the version of rules_ll you want to use:
    #
    #   rules_ll.url = "github:eomii/rules_ll/<version>";
    rules_ll.url = path:../;
  };

  outputs = { self, nixpkgs, flake-utils, rules_ll, ... } @ inputs:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
    ]
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
          openssl_static = (pkgs.openssl.override { static = true; });
          llShell = rules_ll.lib.${system}.llShell;
        in
        {
          devShells = {
            default = llShell {
              unfree = true; # Enable CUDA toolchains.
              packages = [ ];
              env = {
                LL_CFLAGS = "-I${openssl_static.dev}/include";
                LL_LDFLAGS = "-L${openssl_static.out}/lib";
              };
            };
          };
        });
}
