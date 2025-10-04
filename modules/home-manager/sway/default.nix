{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  wofi = lib.getExe pkgs.wofi;
  vicinae = lib.getExe config.services.vicinae.package;
in
{
  config = lib.mkIf (cfg.preferred.wm == "sway") {
    wayland.windowManager.sway = {
      enable = true;
      package = config.wrapped.sway;
      checkConfig = false;
      config = {
        menu =
          if cfg.preferred.menu == "wofi" then
            "${wofi} --prompt 'Search Apps' --show drun"
          else if cfg.preferred.menu == "vicinae" then
            "${vicinae}"
          else
            throw "No preferred menu selected";
        terminal = "${lib.getExe config.wrapped.${cfg.preferred.terminal}}";
        modifier = "Mod4";
      };
    };
    xdg.configFile = (
      builtins.listToAttrs (
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
                      alacritty = lib.getExe config.wrapped.alacritty;
                      bash = lib.getExe pkgs.bash;
                      grim = lib.getExe pkgs.grim;
                      imagemagick = config.wrapped.imagemagick;
                      imv-wayland = lib.getExe' pkgs.imv "imv-wayland";
                      jq = lib.getExe pkgs.jq;
                      ncmpcpp = lib.getExe pkgs.ncmpcpp;
                      notify-send = lib.getExe pkgs.libnotify;
                      slurp = lib.getExe pkgs.slurp;
                      swappy = lib.getExe pkgs.swappy;
                      swaymsg = lib.getExe' config.wrapped.sway "swaymsg";
                      tesseract = lib.getExe pkgs.tesseract;
                      tmux = lib.getExe pkgs.tmux;
                      wl_clipboard = pkgs.wl-clipboard;
                    }
                );
              in
              pkgs.substitute {
                src = ./scripts.d + "/${path}";
                inherit substitutions;
              };
          };
        }) (builtins.attrNames (builtins.readDir ./scripts.d))
      )
    );
  };
  imports = lib.map (p: ./config.d + "/${p}") (
    lib.remove "default.nix" (builtins.attrNames (builtins.readDir ./config.d))
  );
}
