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
  config = lib.mkIf cfg.enable {
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
                    inherit (pkgs)
                      coreutils
                      imagemagick
                      imv
                      mako
                      newt
                      sway
                      ;
                    alacritty = lib.getExe pkgs.alacritty;
                    bash = lib.getExe pkgs.bash;
                    cliphist = lib.getExe pkgs.cliphist;
                    grim = lib.getExe pkgs.grim;
                    jq = lib.getExe pkgs.jq;
                    ncmpcpp = lib.getExe pkgs.ncmpcpp;
                    notify-send = lib.getExe pkgs.libnotify;
                    slurp = lib.getExe pkgs.slurp;
                    swappy = lib.getExe pkgs.swappy;
                    swaync = lib.getExe pkgs.swaynotificationcenter;
                    tesseract = lib.getExe pkgs.tesseract;
                    tmux = lib.getExe pkgs.tmux;
                    trans = lib.getExe pkgs.translate-shell;
                    wofi = lib.getExe pkgs.wofi;
                    wtype = lib.getExe pkgs.wtype;
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
