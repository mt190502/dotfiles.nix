{
  config,
  pkgs,
  ...
}:

(config.lib.nixGL.wrap pkgs.kdePackages.kdeconnect-kde)
