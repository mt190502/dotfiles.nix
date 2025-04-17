{
  config,
  pkgs,
  ...
}:
(config.lib.nixGL.wrap pkgs.alacritty)
