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
    sha256 = "sha256-HkPDTXPkvE1u2VlFv26DaV9VRKjw225Pf1xUBHz0j1A=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-ogADsu7q+vRHUmo3LER0P5g36AsAlV1fa4jkPHe9Wxk=";
  meta = {
    description = "Advanced linux memory monitoring";
    homepage = "https://github.com/xeome/zmem";
  };
}
