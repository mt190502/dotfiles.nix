{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (lib.hasSuffix "linux" pkgs.stdenv.hostPlatform.system) {
    home.file = builtins.listToAttrs (
      lib.map (path: {
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
                  {
                    inherit (config.bin)
                      alacritty
                      bash
                      brightnessctl
                      cliphist
                      dolphin
                      env
                      flatpak
                      foot
                      grim
                      imagemagick
                      imv
                      jq
                      makoctl
                      mpv
                      ncmpcpp
                      newt
                      notify-send
                      pactl
                      playerctl
                      sh
                      slurp
                      swappy
                      sway
                      swayidle
                      swaymsg
                      swaynag
                      tesseract
                      tmux
                      translate-shell
                      vicinae
                      wl-copy
                      wlsunset
                      wofi
                      wtype
                      xev
                      ;
                    lock-screen-function = "${config.bin.systemctl} --user start session-lock";
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
}
