{
  config,
  pkgs,
  ...
}:
(config.lib.nixGL.wrap pkgs.kdePackages.qt6ct)
