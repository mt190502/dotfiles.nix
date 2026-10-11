{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
  ...
}:

rustPlatform.buildRustPackage {
  pname = "matrirc";
  version = "0.1.0-unstable-2025-07-15";

  src = fetchFromGitHub {
    owner = "martinetd";
    repo = "matrirc";
    rev = "45f4d6d5482293162c48a77505fcb20cb0d9278b";
    hash = "sha256-EFpAChNQLAk2LyqJKXawZhwbnWgsVyu3xehcCJLOGxU=";
  };

  cargoHash = "sha256-PaEh0uaftDiOxvzPsaGGU2jutkB69Xu1Z91Co9NFUC4=";

  patches = [ ./files/registration-order.patch ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    sqlite
  ];

  meta = {
    description = "Local IRC gateway for Matrix";
    homepage = "https://github.com/martinetd/matrirc";
    license = lib.licenses.wtfpl;
    maintainers = [ ];
    mainProgram = "matrirc";
  };
}
