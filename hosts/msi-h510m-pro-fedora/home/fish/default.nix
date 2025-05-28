{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager;
in
{
  config = lib.mkIf cfg.fish.enable {
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
        #### Applications
        #################################################
        #~ common ~#
        docker completion fish | source
      '';
      shellAliases = {
        d = "docker";
        sysdup = "sudo dnf --refresh upgrade && nix-channel --update && flatpak update && hm msi-h510m-pro-fedora --update-flake";
      };
    };
  };
}
