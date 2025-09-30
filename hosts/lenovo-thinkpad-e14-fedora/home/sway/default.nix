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
      "eDP-1" = {
        mode = "1920x1200";
        position = "0,0";
      };
    };
    startup = [
      {
        command = "/opt/1Password/1password --silent --password-store=gnome";
      }
    ];
  };
}
