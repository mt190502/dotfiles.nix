{ config, pkgs, ... }:

with pkgs;
rec {
  name = "mpv";
  original = mpv;
  wrap = config.lib.nixGL.wrap original;
}
