{ lib, self, flake-parts-lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options = {
    perSystem = flake-parts-lib.mkPerSystemOption ({ config, options, pkgs, ... }:
      let cfg = config.rules_ll;
      in
      {
        options = {
          rules_ll = {
            pkgs = mkOption {
              type = types.uniq (types.lazyAttrsOf (types.raw or types.unspecified));
              description = lib.mdDoc ''
                Nixpkgs to use in the rules_ll [`settings`](#opt-perSystem.rules_ll.settings).
              '';
              default = pkgs;
              defaultText = lib.literalMD "`pkgs` (module argument)";
            };
            settings = mkOption {
              type = types.submoduleWith {
                modules = [ ./modules/rules_ll.nix ];
                specialArgs = { inherit (cfg) pkgs; };
              };
              default = { };
              description = lib.mdDoc ''
                The rules_ll configuration.
              '';
            };
            installationScript = mkOption {
              type = types.str;
              description = lib.mdDoc "A .bazelrc.ll generator for rules_ll.";
              default = cfg.settings.installationScript;
              defaultText = lib.literalMD "bazelrc contents";
              readOnly = true;
            };
          };
        };
      }
    );
  };
}
