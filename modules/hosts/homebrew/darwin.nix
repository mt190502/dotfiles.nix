{ config, lib, ... }:

let
  cfg = config.moduleopts.darwin.homebrew;
in
{
  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "uninstall";
      };
      brews = [
        "tailscale"
      ];
      casks = [
        "1password"
        "anki"
        "discord"
        "iterm2"
        "jetbrains-toolbox"
        "libreoffice"
        "librewolf"
        "obs"
        "vivaldi"
      ];
    };
  };
}
