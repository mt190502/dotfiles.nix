{ config, pkgs, ... }:

with pkgs;
rec {
  name = "kdeconnect";
  original = kdePackages.kdeconnect-kde;
  wrap = config.lib.nixGL.wrap original;
}
