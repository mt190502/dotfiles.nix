{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager.sway;
  modifier = config.wayland.windowManager.sway.config.modifier;
in
{
  wayland.windowManager.sway.config = lib.mkIf cfg.enable {
    keybindings = {
      "${modifier}+g" = "exec /opt/1Password/1password --quick-access";
    };
    output = {
      "*" = {
        bg = "${config.stylix.image} fill";
      };
      "HDMI-A-4" = {
        mode = "1920x1080";
        position = "0,0";
      };
      "DP-2" = {
        mode = "1920x1080";
        position = "1920,0";
      };
    };
    startup = [
      {
        command = "/opt/1Password/1password --silent --password-store=gnome";
      }
    ];
  };
}
