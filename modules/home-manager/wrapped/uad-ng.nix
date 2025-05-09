{ config, pkgs, ... }:

with pkgs;
rec {
  name = "universal-android-debloater";
  original = universal-android-debloater;
  wrap = config.lib.nixGL.wrap original;
}
