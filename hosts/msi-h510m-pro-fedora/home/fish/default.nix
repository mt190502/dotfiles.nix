{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.fish;
  home = config.home.homeDirectory;
in
{
  config = lib.mkIf cfg.enable {
    programs.fish = {
      functions = {
        dnfnodep = ''
          for i in $argv
            sudo rpm -Uvh --nodeps $(dnf repoquery --location "$i" | head -n 1)
          end
        '';
      };
      shellInit = ''
        #################################################
        #### Home specific fish variables
        #################################################
        export PATH="${home}/.local/share/JetBrains/Toolbox/scripts:${home}/.local/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:${home}/.nix-profile/sbin:${home}/.nix-profile/bin:$PATH";
        export XDG_DATA_DIRS="${home}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:${home}/.local/share:/usr/local/share:/usr/share:${home}/.nix-profile/share:$XDG_DATA_DIRS";

        #################################################
        #### Applications
        #################################################
        #~ common ~#
        docker completion fish | source
      '';
      loginShellInit = ''
        if [ "$(tty)" = "/dev/tty1" ]
          export $(${pkgs.systemd}/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
          export GNOME_KEYRING_CONTROL=/run/user/$(id -u)/keyring
          export SSH_AUTH_SOCK=$GNOME_KEYRING_CONTROL/ssh
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
          if [ "${config.moduleopts.home-manager.preffered-wm}" = "hyprland" ]
            Hyprland &>${config.home.homeDirectory}/.cache/hyprland.log
          else
            XDG_CURRENT_DESKTOP=sway sway &>${config.home.homeDirectory}/.cache/swaywm.log
          end
        end
      '';
      shellAliases = {
        d = "docker";
        sysdup = "sudo dnf --refresh upgrade && nix-channel --update && flatpak update && hm .#msi-h510m-pro-fedora --update-flake";
      };
    };
  };
}
