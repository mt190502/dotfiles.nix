{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager.scripts;
in
{
  options.moduleopts.home-manager.scripts = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "scripts";
    };
  };
  config = lib.mkIf cfg.enable {
    home.file = (
      builtins.listToAttrs (
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
                      alacritty = lib.getExe config.wrapped.alacritty;
                      bash = pkgs.bash;
                      cliphist = lib.getExe pkgs.cliphist;
                      coreutils = pkgs.coreutils;
                      grim = lib.getExe pkgs.grim;
                      imagemagick = config.wrapped.imagemagick;
                      imv = config.wrapped.imv;
                      jq = lib.getExe pkgs.jq;
                      mako = pkgs.mako;
                      ncmpcpp = lib.getExe pkgs.ncmpcpp;
                      newt = pkgs.newt;
                      notify-send = lib.getExe pkgs.libnotify;
                      slurp = lib.getExe pkgs.slurp;
                      swappy = lib.getExe pkgs.swappy;
                      sway = config.wrapped.sway;
                      swaync = lib.getExe pkgs.swaynotificationcenter;
                      tesseract = lib.getExe pkgs.tesseract;
                      tmux = lib.getExe pkgs.tmux;
                      trans = lib.getExe pkgs.translate-shell;
                      wl_clipboard = pkgs.wl-clipboard;
                      wofi = lib.getExe pkgs.wofi;
                      wtype = lib.getExe pkgs.wtype;
                      xev = lib.getExe pkgs.xorg.xev;
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
}
