{ ... }:

{
  wayland.windowManager.sway.config = {
    startup = [
      #~~~ gtk configuration
      {
        command =
          "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XAUTHORITY SSH_AUTH_SOCK GNOME_KEYRING_CONTROL";
      }
      {
        command =
          "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XAUTHORITY SSH_AUTH_SOCK GNOME_KEYRING_CONTROL";
      }
      {
        command =
          "dbus-update-activation-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XAUTHORITY SSH_AUTH_SOCK GNOME_KEYRING_CONTROL";
      }

      #~~~ startup apps
      { command = "$HOME/.config/sway/scripts.d/powermenu.sh --daemonize"; }
      {
        command =
          "/usr/bin/bash -c 'sleep 5 && for app in $(realpath ~/.config/autostart/*); do gio launch $app; done'";
      }
      { command = "/usr/bin/solaar -w hide"; }
      {
        command =
          "/usr/bin/swayidle -w timeout 120 '~/.config/sway/scripts.d/powermenu.sh --lock' timeout 140 'swaymsg output * dpms off' resume 'swaymsg output * dpms on'";
      }
      { command = "/usr/bin/tmux new-session -ds daemonmodetmux"; }
      { command = "/usr/bin/wl-paste -w $HOME/scripts/cliphist store"; }
      { command = "/usr/bin/wlsunset -S '07:00' -s '19:00'"; }
      { command = "/usr/bin/kdeconnectd"; }
      { command = "/usr/libexec/kf6/polkit-kde-authentication-agent-1"; }
      { command = "/usr/libexec/packagekitd"; }
      { command = "$HOME/scripts/pomobar-server"; }

      {
        command = "$HOME/.config/sway/scripts.d/tmux_server.sh";
        always = true;
      }
      {
        command = "$HOME/.config/sway/scripts.d/workspace.sh init 1";
        always = true;
      }
      # { command = "$HOME/.config/sway/scripts.d/screen_setup.sh"; always = true; }

      #~~~ others
      {
        command = "$HOME/.config/sway/scripts.d/autostart.sh";
      }
      # { command = "$HOME/.config/sway/scripts.d/starter.sh"; }
      # { command = "bash -c 'while true; do wpg -m; sleep 1800; done'"; }
    ];
  };
}
