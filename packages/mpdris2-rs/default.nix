{
  pkgs,
  ...
}:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "mpdris2-rs";
  version = "1.0.0-beta.1";
  src = pkgs.fetchFromGitHub {
    owner = "szclsya";
    repo = pname;
    rev = version;
    sha256 = "sha256-c9CI5KaC9wyfnYUvAIdq/4fznb7ehe5qbUiQ9ooPG+M=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-Lbs94OSyLd4hGMUeDGbjaLstd7ACfE7Tbrbz3uAyKoY=";
  meta = {
    description = "MPRIS2 client for MPD written in Rust";
    homepage = "https://github.com/szclsya/mpdris2-rs";
  };
}
