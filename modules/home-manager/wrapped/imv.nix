{ config, pkgs, ... }:

with pkgs;
rec {
  name = "imv";
  original = imv;
  wrap = config.lib.nixGL.wrap original;
}
