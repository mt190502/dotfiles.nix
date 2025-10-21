{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager;
  modifier = config.wayland.windowManager.hyprland.settings."$mod";
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf (cfg.preferred.wm == "hyprland") {
    bind = [
      "${modifier}, g, exec, /opt/1Password/1password --quick-access"
    ];
    monitor = "eDP-1, 1920x1200@60, 0x0, 1";
    exec-once = [
      "/opt/1Password/1password --silent --password-store=gnome"
    ];
  };
  services.hyprpaper.settings = lib.mkIf (cfg.preferred.wm == "hyprland") {
    wallpaper = [
      config.stylix.image
    ];
  };
}
