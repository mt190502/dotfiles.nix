{ config, pkgs, ... }:

{
  wayland.windowManager.sway = {
    systemd = {
      enable = true;
      variables = [
        "DISPLAY"
        "GNOME_KEYRING_CONTROL"
        "NIXOS_OZONE_WL"
        "SSH_AUTH_SOCK"
        "SWAYSOCK"
        "WAYLAND_DISPLAY"
        "XAUTHORITY"
        "XCURSOR_SIZE"
        "XCURSOR_THEME"
        "XDG_CURRENT_DESKTOP"
        "XDG_SESSION_TYPE"
      ];
    };
    config.startup = [
      #~~~ initial
      {
        command = "systemctl --user import-environment DISPLAY GNOME_KEYRING_CONTROL NIXOS_OZONE_WL SSH_AUTH_SOCK SWAYSOCK WAYLAND_DISPLAY XAUTHORITY XCURSOR_SIZE XCURSOR_THEME XDG_CURRENT_DESKTOP XDG_SESSION_TYPE";
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
        command = "/usr/libexec/xfce-polkit";
      }
      {
        command = "$HOME/.config/sway/scripts.d/tmux_server.sh";
        always = true;
      }
      {
        command = "$HOME/.config/sway/scripts.d/workspace.sh init 1";
        always = true;
      }
      {
        command = "/opt/1Password/1password --ozone-platform=wayland --ozone-platform-hint=auto --password-store=gnome --silent";
        # command = "${config.wrappedPkgs.onepassword-gui}/bin/1password --silent";       #~ not work on home manager only setups
      }

      #~~~ others
      { command = "$HOME/.config/sway/scripts.d/autostart.sh"; }
    ];
  };
}
