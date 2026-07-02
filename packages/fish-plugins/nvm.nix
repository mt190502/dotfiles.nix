{ pkgs, ... }:

pkgs.fetchFromGitHub {
  owner = "jorgebucaran";
  repo = "nvm.fish";
  rev = "2.2.17";
  sha256 = "sha256-GTEkCm+OtxMS3zJI5gnFvvObkrpepq1349/LcEPQRDo=";
}
