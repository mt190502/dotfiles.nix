{
  config,
  flakeName,
  lib,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  home = config.home.homeDirectory;
in
{
  config = lib.mkIf cfg.fish.enable {
    programs.fish = {
      shellAliases = {
        kc = "kubectx";
        sysdup = lib.mkForce "nix-channel --update && sudo nix-channel --update && sudo darwin-rebuild switch --flake ${home}/Projects/000_myprojects/dotfiles.nix#${flakeName}";
        sysclean = lib.mkForce "nix-collect-garbage -d";
      };
    };
  };
}
