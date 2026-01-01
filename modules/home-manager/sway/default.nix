{
  config,
  lib,
  pkgs,
  system,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  wofi = lib.getExe pkgs.wofi;
  vicinae = lib.getExe pkgs.vicinae;
in
{
  config = lib.mkIf (cfg.preferred.wm == "sway" && lib.hasSuffix "linux" system) {
    wayland.windowManager.sway = {
      enable = true;
      checkConfig = false;
      config = {
        menu =
          if cfg.preferred.menu == "wofi" then
            "${wofi} --prompt 'Search Apps' --show drun"
          else if cfg.preferred.menu == "vicinae" then
            "${vicinae}"
          else
            throw "No preferred menu selected";
        terminal = "${lib.getExe pkgs.${cfg.preferred.terminal}}";
        modifier = "Mod4";
      };
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
                  (
                    with pkgs;
                    {
                      inherit imagemagick;
                      alacritty = lib.getExe alacritty;
                      bash = lib.getExe bash;
                      grim = lib.getExe grim;
                      imv-wayland = lib.getExe' imv "imv-wayland";
                      jq = lib.getExe jq;
                      ncmpcpp = lib.getExe ncmpcpp;
                      notify-send = lib.getExe libnotify;
                      slurp = lib.getExe slurp;
                      swappy = lib.getExe swappy;
                      swaymsg = lib.getExe' sway "swaymsg";
                      swaynag = lib.getExe' sway "swaynag";
                      tesseract = lib.getExe tesseract;
                      tmux = lib.getExe tmux;
                    }
                  )
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
  imports = lib.map (p: ./config.d + "/${p}") (
    lib.remove "default.nix" (builtins.attrNames (builtins.readDir ./config.d))
  );
}
