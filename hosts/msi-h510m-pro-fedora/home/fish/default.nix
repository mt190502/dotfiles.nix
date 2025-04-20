{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.fish;
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
      loginShellInit = ''
        if [ $XDG_VTNR = 1 ]; and [ $SHLVL = 1 ]; and [ ! $container ]
          export $(${pkgs.systemd}/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
          export GNOME_KEYRING_CONTROL=/run/user/$(id -u)/keyring
          export SSH_AUTH_SOCK=$GNOME_KEYRING_CONTROL/ssh
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
          XDG_CURRENT_DESKTOP=sway sway &>${config.home.homeDirectory}/.cache/swaywm.log
        end
      '';
      shellAliases = {
        d = "docker";
        sysdup = "sudo dnf --refresh upgrade && nix-channel --update && flatpak update && hm .#msi-h510m-pro-fedora";
      };
    };
  };
}
