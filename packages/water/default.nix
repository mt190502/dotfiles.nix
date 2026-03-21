{ pkgs, ... }:

with pkgs;
buildGoModule rec {
  pname = "water";
  version = "e8eead5";
  src = fetchFromGitHub {
    owner = "bouquet2";
    repo = pname;
    rev = version;
    sha256 = "sha256-gg7odE2ENLUhlMULUjkpCoCdNUTKhLNij5WGzCnglr0=";
  };
  vendorHash = "sha256-RVC25J0969SMh1rIir/Mi6LIrEtk7WAT4NimJqczGRM=";
  meta = {
    description = "A terminal-based talos/kubernetes upgrader tool";
    homepage = "https://github.com/bouquet2/water";
  };
}
