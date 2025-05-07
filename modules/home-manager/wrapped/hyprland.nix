{ config, pkgs, ... }:

with pkgs;
rec {
  name = "hyprland";
  original = hyprland;
  wrap = config.lib.nixGL.wrap original;
}
