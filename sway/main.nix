{ ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    checkConfig = true;
    config = { modifier = "Mod4"; };
  };

  imports = [
    ./config.d/colors.nix
    ./config.d/environments.nix
    ./config.d/inputs.nix
    ./config.d/others.nix
    ./config.d/outputs.nix
    ./config.d/settings.nix
    ./config.d/shortcuts.nix
    ./config.d/windowrules.nix
  ];
}
