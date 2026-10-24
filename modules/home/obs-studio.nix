{ pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override { browserSupport = false; };
  };
}
