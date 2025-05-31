{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager;
in
{
  config = lib.mkIf cfg.fish.enable {
    programs.fish = {
      shellInit = ''
        #################################################
        #### Applications
        #################################################
        #~ common ~#
        docker completion fish | source
      '';
      shellAliases = {
        d = "docker";
        sysdup = "sudo pacman -Syyu && nix-channel --update && flatpak update && hm msi-h510m-pro-arch --update-flake";
      };
    };
  };
}
