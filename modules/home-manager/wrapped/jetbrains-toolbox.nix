{ config, pkgs, ... }:

with pkgs;
rec {
  name = "jetbrains-toolbox";
  original = jetbrains-toolbox;
  wrap = config.lib.nixGL.wrap original;
}
