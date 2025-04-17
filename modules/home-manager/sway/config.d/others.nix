{ config, lib, pkgs, ... }:

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
      xdgAutostart = true;
    };

    config.startup = [
      #~~~ initial
      {
        command = "systemctl --user import-environment DISPLAY GNOME_KEYRING_CONTROL NIXOS_OZONE_WL SSH_AUTH_SOCK SWAYSOCK WAYLAND_DISPLAY XAUTHORITY XCURSOR_SIZE XCURSOR_THEME XDG_CURRENT_DESKTOP XDG_SESSION_TYPE";
      }

      #~~~ startup apps
      { command = "${config.home.homeDirectory}/.config/sway/scripts.d/powermenu.sh --daemonize"; }
      # {
      # command = "${config.home.homeDirectory}/bin/bash -c 'sleep 5 && for app in $(realpath ${config.home.homeDirectory}/.config/autostart/*); do ${pkgs.glib}/bin/gio launch $app; done'";
      # }
      {
        command = if config.home.username != "nixos" then "/usr/bin/solaar -w hide" else "";
      }
      {
        command = "${lib.getExe pkgs.swayidle} -w timeout 120 '${config.home.homeDirectory}/.config/sway/scripts.d/powermenu.sh --lock' timeout 140 '${config.wrapped.sway}/bin/swaymsg output * dpms off' resume '${config.wrapped.sway}/bin/swaymsg output * dpms on'";
      }
      { command = "${lib.getExe pkgs.tmux} new-session -ds daemonmodetmux"; }
      {
        command = "${pkgs.wl-clipboard}/bin/wl-paste -w ${lib.getExe pkgs.cliphist} store";
      }
      { command = "${lib.getExe pkgs.wlsunset} -S '07:00' -s '19:00'"; }
      { command = if config.home.username == "fedora" then "/usr/libexec/xfce-polkit" else ""; }
      {
        command = "${config.home.homeDirectory}/.config/sway/scripts.d/tmux_server.sh";
        always = true;
      }
      {
        command = "${config.home.homeDirectory}/.config/sway/scripts.d/workspace.sh init 1";
        always = true;
      }
      {
        command =
          if config.home.username != "nixos" then
            "/opt/1Password/1password --silent --password-store=gnome"
          else
            "";
        # command = "${config.wrapped.onepassword-gui}/bin/1password --silent";       #~ not work on home manager only setups
      }

      #~~~ others
      { command = "${config.home.homeDirectory}/.config/sway/scripts.d/autostart.sh"; }
    ];
  };
}
