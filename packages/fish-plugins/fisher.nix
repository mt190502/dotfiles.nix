{ pkgs, ... }:

pkgs.fetchFromGitHub {
  owner = "jorgebucaran";
  repo = "fisher";
  rev = "4.4.8";
  sha256 = "sha256-Sf671UGOQXtOMrqoEOIBG5TCt0p5fd+aKGF2ExImbbs=";
}
