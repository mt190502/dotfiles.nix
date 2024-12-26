{ config, lib, pkgs, ... }:

{
  options.pkgconfig.sway = {
    enable = lib.mkEnableOption {
      type = lib.types.bool;
      default = true;
      description = "Enable sway window manager configuration.";
    };
  };
  config.wayland.windowManager.sway = {
    enable = config.pkgconfig.sway.enable;
    checkConfig = false;
    config = { modifier = "Mod4"; };
  };

  imports = [
    ./config.d/colors.nix
    ./config.d/environments.nix
    ./config.d/inputs.nix
    ./config.d/others.nix
    ./config.d/outputs.nix
    ./config.d/settings.nix
    ./config.d/shortcuts.nix
    ./config.d/windowrules.nix
  ];
}
