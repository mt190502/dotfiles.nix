{
  config,
  lib,
  pkgs,
  ...
}:

let
  player =
    if config.preferences.mediaplayer == "ncmpcpp" then
      config.bin.ncmpcpp
    else if config.preferences.mediaplayer == "rmpc" then
      config.bin.rmpc
    else
      throw "No preferred music player selected";
in
{
  config = {
    preferences = {
      desktopenv = lib.mkDefault "sway";
      lock-app = lib.mkDefault "swaylock";
      notifier = lib.mkDefault "swaync";
    };
    xdg.configFile = builtins.listToAttrs (
      lib.map (path: {
        name = "sway/scripts.d/${path}";
        value = {
          executable = true;
          source =
            let
              substitutions = lib.flatten (
                lib.mapAttrsToList
                  (k: v: [
                    "--replace"
                    "@${k}@"
                    "${v}"
                  ])
                  {
                    inherit (config.bin)
                      alacritty
                      bash
                      foot
                      grim
                      imagemagick
                      imv
                      jq
                      ncmpcpp
                      notify-send
                      slurp
                      swappy
                      swaymsg
                      swaynag
                      tesseract
                      tmux
                      wl-copy
                      ;
                    inherit player;
                    preferred_terminal = config.preferences.terminal;
                  }
              );
            in
            pkgs.substitute {
              src = ./scripts.d + "/${path}";
              inherit substitutions;
            };
        };
      }) (builtins.attrNames (builtins.readDir ./scripts.d))
    );
  };
  imports = [
    # ./cliphist.nix
    ./kde-apps-wm-fix.nix
    # ./mako.nix
    ./qt-apps-wm-fix.nix
    ./swappy.nix
    ./sway.nix
    ./swaylock.nix
    ./swaynag.nix
    ./swaync.nix
    ./waybar.nix
    # ./wofi.nix
  ];
}
