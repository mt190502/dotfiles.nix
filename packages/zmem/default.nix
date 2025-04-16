{
  pkgs,
  ...
}:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "zmem";
  version = "master";
  src = pkgs.fetchFromGitHub {
    owner = "xeome";
    repo = pname;
    rev = version;
    sha256 = "sha256-0BCt+Jz/571dIyju89b4H9n0byCnEEt3pdUzJ3EUVOM=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-cjDOGANGG9gfdW5OdEveGbhhYxxL96l1YGCVKMyVa1A=";
  meta = {
    description = "Advanced linux memory monitoring";
    homepage = "https://github.com/xeome/zmem";
  };
}
