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
      brews = [ ];
      casks = [
        "1password"
        "1password-cli"
        "alt-tab"
        "anki"
        "discord"
        "iterm2"
        "jetbrains-toolbox"
        "keyboardcleantool"
        "libreoffice"
        "librewolf"
        "logi-options+"
        "obs"
        "openvpn-connect"
        "raycast"
        "shottr"
        "tailscale-app"
        "vivaldi"
        "whatsapp"
      ];
    };
  };
}
