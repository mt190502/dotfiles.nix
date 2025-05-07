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
    sha256 = "sha256-yVi9kTkFM5z1F+3S9Wvl90wdvgsI9ZhH3zfQC7PzUBs=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-AYcyOCnxSTkRLIb4zuIiTiYFyIN9JIzA2rTDBqyx8Pg=";
  meta = {
    description = "Advanced linux memory monitoring";
    homepage = "https://github.com/xeome/zmem";
  };
}
