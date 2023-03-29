{ pkgs, ... }:
{
  # Default hooks
  trailing-whitespace-fixer = {
    enable = true;
    name = "trailing-whitespace";
    description = "Remove trailing whitespace";
    entry = "${pkgs.python311Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
    excludes = [ "^patches/" ];
    types = [ "text" ];
  };
  end-of-file-fixer = {
    enable = true;
    name = "end-of-file-fixer";
    description = "Remove trailing whitespace";
    entry = "${pkgs.python311Packages.pre-commit-hooks}/bin/end-of-file-fixer";
    excludes = [ "^patches/" "png" ];
    types = [ "text" ];
  };
  fix-byte-order-marker = {
    enable = true;
    name = "fix-byte-order-marker";
    entry = "${pkgs.python311Packages.pre-commit-hooks}/bin/fix-byte-order-marker";
    types = [ "text" ];
  };
  mixed-line-ending = {
    enable = true;
    name = "mixed-line-ending";
    entry = "${pkgs.python311Packages.pre-commit-hooks}/bin/mixed-line-ending";
    excludes = [ "png" ];
    types = [ "text" ];
  };
  check-case-conflict = {
    enable = true;
    name = "check-case-conflict";
    entry = "${pkgs.python311Packages.pre-commit-hooks}/bin/check-case-conflict";
    types = [ "text" ];
  };
  detect-private-key = {
    enable = true;
    name = "detect-private-key";
    entry = "${pkgs.python311Packages.pre-commit-hooks}/bin/detect-private-key";
    types = [ "text" ];
  };

  # Starlark
  bazel-buildifier-format = {
    enable = true;
    name = "buildifier format";
    description = "Format Starlark";
    entry = "${pkgs.bazel-buildtools}/bin/buildifier";
    types = [ "bazel" ];
  };
  bazel-buildifier-lint = {
    enable = true;
    name = "buildifier lint";
    description = "Lint Starlark";
    entry = "${pkgs.bazel-buildtools}/bin/buildifier -lint=warn";
    types = [ "bazel" ];
  };

  # YAML
  yamllint = {
    enable = true;
    excludes = [ "^styles/" ];
  };

  # Bash/Shell
  shellcheck = {
    enable = true;
    excludes = [ "png" ];
    types_or = [ "shell" ];
  };

  # Nix
  nixpkgs-fmt.enable = true;

  # C++
  clang-format15 = {
    enable = true;
    name = "clang-format";
    types_or = [ "c" "c++" ];
    entry = "${pkgs.llvmPackages_15.libclang}/bin/clang-format";
    excludes = [ "^(docs/|^llvm-project-overlay/)" ];
  };

  # Markdown
  markdownlint = {
    enable = true;
    excludes = [ "^(docs/reference/|docs/rules/|styles/)" ];
    types = [ "markdown" ];
  };

  # Vale
  vale = {
    enable = true;
    name = "vale";
    entry = "${pkgs.vale}/bin/vale";
    excludes = [ "^styles/" ];
    types = [ "markdown" ];
  };
}
