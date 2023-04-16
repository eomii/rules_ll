{ pkgs, wrappedBazel, tag }:

let

  llScript = (name: file:
    (pkgs.writeScriptBin name (builtins.readFile file)).overrideAttrs (script: {
      buildCommand = "${script.buildCommand}\n patchShebangs $out";
    })
  );

  # Prettier colors.
  cmd = (string: "\\E[32m" + string + "\\033[0m");
  dir = (string: "\\E[34m\\033[1m" + string + "\\033[0m");
  fat = (string: "\\E[1m" + string + "\\033[0m");
  opt = (string: "\\E[33m" + string + "\\033[0m");


  ll_docs = llScript "docs" ./docs.sh;
  ll_patch = llScript "overlay" ./overlay.sh;
  ll_release = llScript "module" ./module.sh;
  ll_rbe = import ./rbe.nix { inherit pkgs wrappedBazel tag; };

in

pkgs.writeShellScriptBin "ll" ''

if [[ "$1" == "docs" ]]; then
${ll_docs}/bin/docs
elif [[ "$1" == "overlay" ]]; then
${ll_patch}/bin/overlay
elif [[ "$1" == "module" ]]; then
${ll_release}/bin/module $2
elif [[ "$1" == "rbe" ]]; then
${ll_rbe}/bin/rbe $2
else

printf '
The ${fat "ll"} development tool for rules_ll.

ll ${cmd "docs"}:\tBuild the documentation in ${dir "docs/"}.

ll ${cmd "overlay"}:\tBuild the overlay patch at ${dir "patches/"}${cmd "rules_ll_overlay_patch.diff"}.
\t\tRequires a copy of the llvm-project in the rules_ll project root.

ll ${cmd "module"} ${opt "tag"}:\tGiven a git tag, create a directory ${dir "<tag>"} for copy-pasting into a
\t\tbazel registry.

ll ${cmd "rbe"}:\t\tBuild the toolchains in ${dir "rbe/default/"}.

'

fi''
