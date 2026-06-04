{
  config,
  lib,
  pkgs,
  ...
}:

let
  hasDesktop = config.preferences.desktopenv != "none";

  guiBinEntries = lib.optionalAttrs hasDesktop {
    inherit (config.bin)
      brightnessctl
      cliphist
      dolphin
      flatpak
      foot
      grim
      imv
      makoctl
      newt
      notify-send
      pactl
      pavucontrol
      playerctl
      slurp
      swappy
      sway
      swayidle
      swaymsg
      swaynag
      swaync
      vicinae
      wl-copy
      wlsunset
      wofi
      wtype
      xev
      ;
  };

  guiScripts = [
    "easy-tesseract"
    "mako-dnd-toggle"
    "powermenu"
    "wofimoji"
    "xdg-screen-cast"
  ];
in
{
  config = lib.mkIf (lib.hasSuffix "linux" pkgs.stdenv.hostPlatform.system) {
    home.file = builtins.listToAttrs (
      lib.map
        (path: {
          name = ".local/bin/${path}";
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
                    (
                      {
                        inherit (config.bin)
                          alacritty
                          bash
                          env
                          imagemagick
                          jq
                          mpv
                          ncmpcpp
                          sh
                          tesseract
                          tmux
                          translate-shell
                          ;
                        lock-screen-function = "${config.bin.systemctl} --user start session-lock";
                      }
                      // guiBinEntries
                    )
                );
              in
              pkgs.substitute {
                src = ./scripts.d + "/${path}";
                inherit substitutions;
              };
          };
        })
        (
          builtins.attrNames (
            removeAttrs (builtins.readDir ./scripts.d) (lib.optionals (!hasDesktop) guiScripts)
          )
        )
    );
  };
}
