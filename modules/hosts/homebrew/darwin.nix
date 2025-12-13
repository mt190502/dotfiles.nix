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
        "caffeine"
        "discord"
        "freelens"
        "gcloud-cli"
        "iina"
        "iterm2"
        "jetbrains-toolbox"
        "keyboardcleantool"
        "libreoffice"
        "librewolf"
        "logi-options+"
        "jordanbaird-ice@beta"
        "obs"
        "openvpn-connect"
        "parsec"
        "raycast"
        "shottr"
        "tailscale-app"
        "vivaldi"
        "whatsapp"
      ];
      taps = [ ];
    };
  };
}
