{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager;
in
{
  config = lib.mkIf cfg.fish.enable {
    programs.fish = {
      shellAliases = {
        sysclean = "sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      };
    };
  };
}