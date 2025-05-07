{ config, pkgs, ... }:

with pkgs;
rec {
  name = "nwg-displays";
  original = nwg-displays;
  wrap = config.lib.nixGL.wrap original;
}
