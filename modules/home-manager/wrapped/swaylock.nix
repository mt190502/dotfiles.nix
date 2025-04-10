{
  config,
  pkgs,
  ...
}:
(config.lib.nixGL.wrap pkgs.swaylock)
