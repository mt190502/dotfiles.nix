{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  terminal = lib.getExe config.wrapped.${cfg.preferred.terminal};
  wofi = lib.getExe pkgs.wofi;
  vicinae = lib.getExe config.services.vicinae.package;
in
{
  config = lib.mkIf (cfg.preferred.wm == "hyprland") {
    services.hyprpaper = {
      enable = true;
      package = pkgs.hyprpaper;
      settings = {
        ipc = "on";
        splash = false;
        splash_offset = 2.0;
      };
    };
    wayland.windowManager.hyprland = {
      enable = true;
      package = config.wrapped.hyprland;
      settings = {
        "$mod" = "SUPER_L";
        "$alt" = "ALT";
        "$menu" =
          if cfg.preferred.menu == "wofi" then
            "${wofi} --prompt 'Search Apps' --show drun"
          else if cfg.preferred.menu == "vicinae" then
            "${vicinae}"
          else
            throw "No preferred menu selected";
        "$terminal" = "${terminal}";
      };
    };
    xdg.configFile = (
      builtins.listToAttrs (
        lib.map (path: {
          name = "hypr/scripts.d/${path}";
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
                      bash = lib.getExe pkgs.bash;
                      hyprctl = lib.getExe' config.wrapped.hyprland "hyprctl";
                      jq = lib.getExe pkgs.jq;
                      ncmpcpp = lib.getExe pkgs.ncmpcpp;
                      notify-send = lib.getExe pkgs.libnotify;
                      slurp = lib.getExe pkgs.slurp;
                      tmux = lib.getExe pkgs.tmux;
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
