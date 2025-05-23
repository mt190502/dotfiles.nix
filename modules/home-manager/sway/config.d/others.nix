{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
  swaymsg = lib.getExe' config.wrapped.sway "swaymsg";
in
{
  wayland.windowManager.sway = {
    systemd = {
      enable = true;
      variables = [
        "DISPLAY"
        "GNOME_KEYRING_CONTROL"
        "LD_LIBRARY_PATH"
        "NIXOS_OZONE_WL"
        "PATH"
        "SSH_AUTH_SOCK"
        "SWAYSOCK"
        "WAYLAND_DISPLAY"
        "XAUTHORITY"
        "XCURSOR_SIZE"
        "XCURSOR_THEME"
        "XDG_CURRENT_DESKTOP"
        "XDG_DATA_DIRS"
        "XDG_SESSION_TYPE"
      ];
      xdgAutostart = true;
    };

    config.startup = [
      #~~~ initial
      {
        command = "systemctl --user import-environment DISPLAY GNOME_KEYRING_CONTROL LD_LIBRARY_PATH NIXOS_OZONE_WL PATH SSH_AUTH_SOCK SWAYSOCK WAYLAND_DISPLAY XAUTHORITY XCURSOR_SIZE XCURSOR_THEME XDG_CURRENT_DESKTOP XDG_DATA_DIRS XDG_SESSION_TYPE";
      }

      #~~~ startup apps
      {
        command = "${lib.getExe pkgs.swayidle} -w timeout 120 '${home}/.local/bin/powermenu --lock' timeout 140 '${swaymsg} output * dpms off' resume '${swaymsg} output * dpms on'";
      }
      { command = "${lib.getExe pkgs.tmux} new-session -ds daemonmodetmux"; }
      { command = "${lib.getExe pkgs.wlsunset} -S '07:00' -s '19:00'"; }
      {
        command = "${home}/.local/bin/tmux-server";
        always = true;
      }
      {
        command = "${home}/.config/sway/scripts.d/workspace.sh init 1";
        always = true;
      }

      #~~~ others
      { command = "${home}/.local/bin/autostart"; }
    ];
  };
}
