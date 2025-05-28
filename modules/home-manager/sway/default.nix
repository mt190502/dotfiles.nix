{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
in
{
  options.moduleopts.home-manager.sway = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "sway";
    };
  };
  config = lib.mkIf cfg.sway.enable {
    wayland.windowManager.sway = {
      enable = lib.mkIf (cfg.prefered-wm == "sway") true;
      package = config.wrapped.sway;
      checkConfig = false;
      config = {
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
                      jq = lib.getExe pkgs.jq;
                      ncmpcpp = lib.getExe pkgs.ncmpcpp;
                      notify-send = lib.getExe pkgs.libnotify;
                      slurp = lib.getExe pkgs.slurp;
                      swaymsg = lib.getExe' config.wrapped.sway "swaymsg";
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
