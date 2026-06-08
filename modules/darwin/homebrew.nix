{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      extraFlags = [ "--force" ];
    };
    brews = [
      "siege"
    ];
    casks = [
      "1password"
      "1password-cli"
      "anki"
      "caffeine"
      "discord"
      "finetune"
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
      "the-unarchiver"
      "vivaldi"
      "whatsapp"
    ];
    taps = [ ];
  };
}
