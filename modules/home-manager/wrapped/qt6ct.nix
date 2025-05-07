{ config, pkgs, ... }:

with pkgs;
rec {
  name = "qt6ct";
  original = kdePackages.qt6ct;
  wrap = config.lib.nixGL.wrap original;
}
