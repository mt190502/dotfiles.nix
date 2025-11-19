{ config, pkgs-unstable, ... }:

with pkgs-unstable;
rec {
  name = "jetbrains-toolbox";
  original = jetbrains-toolbox;
  wrap = config.lib.nixGL.wrap original;
}
