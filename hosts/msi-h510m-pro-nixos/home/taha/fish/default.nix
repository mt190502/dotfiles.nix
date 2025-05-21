{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  home = config.home.homeDirectory;
in
{
  config = lib.mkIf cfg.fish.enable {
    programs.fish = {
      shellInit = ''
        #################################################
        #### Home specific fish variables
        #################################################
        export PATH="${home}/.local/share/JetBrains/Toolbox/scripts:${home}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:${home}/.nix-profile/sbin:${home}/.nix-profile/bin:$PATH";
        export XDG_DATA_DIRS="${home}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:${home}/.local/share:/usr/local/share:${home}/.nix-profile/share:$XDG_DATA_DIRS";
      '';
      loginShellInit = ''
        if [ "$(tty)" = "/dev/tty1" ]
          export $(${pkgs.systemd}/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
          export GNOME_KEYRING_CONTROL=/run/user/$(id -u)/keyring
          export SSH_AUTH_SOCK=$GNOME_KEYRING_CONTROL/ssh
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
          if [ "${cfg.prefered-wm}" = "hyprland" ]
            Hyprland &>${home}/.cache/hyprland.log
          else
            XDG_CURRENT_DESKTOP=sway sway &>${home}/.cache/swaywm.log
          end
        end
      '';
    };
  };
}
