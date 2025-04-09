{
  config,
  pkgs,
  ...
}:

(config.lib.nixGL.wrap pkgs.jetbrains-toolbox)
