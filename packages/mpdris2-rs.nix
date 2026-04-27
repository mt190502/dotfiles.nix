{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "mpdris2-rs";
  version = "v1.1.1";
  src = fetchFromGitHub {
    owner = "szclsya";
    repo = pname;
    rev = version;
    sha256 = "sha256-oiyqK7vj41d9bsXBtenc477SOrVHRkXpFljkN8MjdQg=";
  };
  cargoHash = "sha256-xdgUKU9YiaC3o1uH38ZjvQgR78B/1LqTPis4+XqinQ8=";
  meta = {
    description = "MPRIS2 client for MPD written in Rust";
    homepage = "https://github.com/szclsya/mpdris2-rs";
    mainProgram = "mpdris2-rs";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
  };
}
