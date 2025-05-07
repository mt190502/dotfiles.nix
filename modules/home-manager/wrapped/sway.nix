{ config, pkgs, ... }:

with pkgs;
rec {
  name = "sway";
  original = swayfx;
  wrap = config.lib.nixGL.wrap original;
}
