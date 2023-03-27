{
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
          ll_shell = rules_ll.mkLlShell.${system};
        in
        {
          devShells = {
            default = ll_shell {
              unfree = true; # Enable CUDA toolchains.
              deps = [ ];
              env = {
                LL_CFLAGS = "-I${openssl_static.dev}/include";
                LL_LDFLAGS = "-L${openssl_static.out}/lib";
              };
            };
          };
        });
}
