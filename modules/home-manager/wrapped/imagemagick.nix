{ config, pkgs, ... }:

with pkgs;
rec {
  name = "imagemagick";
  original = imagemagick;
  wrap = config.lib.nixGL.wrap original;
}
