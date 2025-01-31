{ config, pkgs, ... }:

{
  wayland.windowManager.sway = {
    config.startup = [
      #~~~ gtk configuration
      {
        command = "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XAUTHORITY SSH_AUTH_SOCK GNOME_KEYRING_CONTROL";
      }
      {
        command = "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XAUTHORITY SSH_AUTH_SOCK GNOME_KEYRING_CONTROL";
      }
      {
        command = "dbus-update-activation-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XAUTHORITY SSH_AUTH_SOCK GNOME_KEYRING_CONTROL";
      }

      #~~~ startup apps
      { command = "$HOME/.config/sway/scripts.d/powermenu.sh --daemonize"; }
      {
        command = "/usr/bin/bash -c 'sleep 5 && for app in $(realpath ~/.config/autostart/*); do gio launch $app; done'";
      }
      { command = "/usr/bin/solaar -w hide"; }
      {
        command = "${pkgs.swayidle}/bin/swayidle -w timeout 120 '~/.config/sway/scripts.d/powermenu.sh --lock' timeout 140 '${config.wrappedPkgs.sway}/bin/swaymsg output * dpms off' resume '${config.wrappedPkgs.sway}/bin/swaymsg output * dpms on'";
      }
      { command = "${pkgs.tmux}/bin/tmux new-session -ds daemonmodetmux"; }
      {
        command = "${pkgs.wl-clipboard}/bin/wl-paste -w ${pkgs.cliphist}/bin/cliphist store";
      }
      { command = "${pkgs.wlsunset}/bin/wlsunset -S '07:00' -s '19:00'"; }
      {
        command = "/usr/bin/env XDG_CURRENT_DESKTOP=KDE /usr/libexec/kf6/polkit-kde-authentication-agent-1";
      }

      {
        command = "$HOME/.config/sway/scripts.d/tmux_server.sh";
        always = true;
      }
      {
        command = "$HOME/.config/sway/scripts.d/workspace.sh init 1";
        always = true;
      }

      #~~~ others
      {
        command = "$HOME/.config/sway/scripts.d/autostart.sh";
      }
    ];
  };
}
