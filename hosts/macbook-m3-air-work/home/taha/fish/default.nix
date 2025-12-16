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
        sysdup = lib.mkForce "nix-channel --update && sudo nix-channel --update && cd ${home}/Projects/000_myprojects/dotfiles.nix && nix flake update && sudo darwin-rebuild switch --flake .#${flakeName}";
        sysclean = lib.mkForce "nix-collect-garbage -d";
      };
      shellInit = ''
        steampipe completion fish | source
      '';
    };
  };
}
