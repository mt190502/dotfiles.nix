{ config, pkgs, ... }:

with pkgs;
rec {
  name = "qt5ct";
  original = libsForQt5.qt5ct;
  wrap = config.lib.nixGL.wrap original;
}
