{ pkgs, }:

pkgs.buildGoModule rec {
  pname = "bazel-toolchains";
  version = "5.1.2";

  src = pkgs.fetchFromGitHub {
    owner = "bazelbuild";
    repo = "bazel-toolchains";
    rev = "v${version}";
    sha256 = "sha256-J1RFrDGBF7YR5O4D/kNNu6fkxImHpLR+fxhp+R1MaGE=";
  };

  vendorSha256 = "sha256-E6PylI2prXCXqOUYgYi5nZ4qptqOqbcaOquDfEkhaQ4=";

  meta = with pkgs.lib; {
    description = "Generate Bazel toolchain configs for remote execution.";
    homepage = "https://github.com/bazelbuild/bazel-toolchains";
    license = licenses.asl20;
    maintainers = [ maintainers.aaronmondal ];
  };
}
