{
  config,
  flakeName,
  lib,
  ...
}:

{
  programs.fish = {
    shellAliases = {
      sysdup = lib.mkForce "nix-channel --update && sudo nix-channel --update && cd ${config.home.homeDirectory}/Projects/000_myprojects/dotfiles.nix && nix flake update && sudo darwin-rebuild switch --flake .#${flakeName}";
      sysclean = lib.mkForce "nix-collect-garbage -d";
    };
  };
}
