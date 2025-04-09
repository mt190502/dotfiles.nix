{
  config,
  pkgs,
  ...
}:
(config.lib.nixGL.wrap pkgs.libsForQt5.qt5ct)
