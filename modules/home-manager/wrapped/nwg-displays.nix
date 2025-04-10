{
  config,
  pkgs,
  ...
}:

(config.lib.nixGL.wrap pkgs.nwg-displays)
