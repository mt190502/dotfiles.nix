{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
in
{
  wayland.windowManager.hyprland = {
    systemd = {
      enable = true;
      variables = [
        "DISPLAY"
        "GNOME_KEYRING_CONTROL"
        "HYPRLAND_INSTANCE_SIGNATURE"
        "LD_LIBRARY_PATH"
        "NIXOS_OZONE_WL"
        "PATH"
        "SSH_AUTH_SOCK"
        "WAYLAND_DISPLAY"
        "XAUTHORITY"
        "XCURSOR_SIZE"
        "XCURSOR_THEME"
        "XDG_CURRENT_DESKTOP"
        "XDG_DATA_DIRS"
        "XDG_SESSION_TYPE"
      ];
      enableXdgAutostart = true;
    };

    settings = {
      exec-once = [
        "systemctl --user import-environment DISPLAY GNOME_KEYRING_CONTROL LD_LIBRARY_PATH NIXOS_OZONE_WL PATH SSH_AUTH_SOCK SWAYSOCK WAYLAND_DISPLAY XAUTHORITY XCURSOR_SIZE XCURSOR_THEME XDG_CURRENT_DESKTOP XDG_DATA_DIRS XDG_SESSION_TYPE"
        "${home}/.local/bin/autostart"
        "${lib.getExe pkgs.tmux} new-session -ds daemonmodetmux"
        "${lib.getExe pkgs.wlsunset} -S '07:00' -s '19:00'"
      ];
      exec = [
        "${home}/.config/hypr/scripts.d/tmux_server.sh"
      ];
    };
  };
}
