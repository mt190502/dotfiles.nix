{
  pkgs,
  ...
}:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "zmem";
  version = "c3cd777";
  src = pkgs.fetchFromGitHub {
    owner = "xeome";
    repo = pname;
    rev = version;
    sha256 = "sha256-/+qtmXUl8MR34NsW7CLoc5MGBTkkcmHlyG0PTCNJ4TY=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-qKH+LUntScUX67+lpW3+88wiVSc99Tw7QkFEvs5WuVg=";
  meta = {
    description = "Advanced linux memory monitoring";
    homepage = "https://github.com/xeome/zmem";
  };
}
