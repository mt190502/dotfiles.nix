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
    sha256 = "sha256-E9H6bjmWZx35fZo/ZPvJL1w/YQ34pJ7z81YbB5fUZSU=";
  };
  cargoHash = "sha256-rA/za8fc2RiURaiijc49y+2QBcS6cDavZQFjVh+7Iow=";
  meta = {
    description = "MPRIS2 client for MPD written in Rust";
    homepage = "https://github.com/szclsya/mpdris2-rs";
    mainProgram = "mpdris2-rs";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
  };
}