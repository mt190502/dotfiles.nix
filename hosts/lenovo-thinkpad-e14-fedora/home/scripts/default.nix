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
                  (
                    with pkgs;
                    {
                      alacritty = lib.getExe alacritty;
                      bash = lib.getExe bash;
                      cliphist = lib.getExe cliphist;
                      coreutils = coreutils;
                      grim = lib.getExe grim;
                      imagemagick = imagemagick;
                      imv = imv;
                      jq = lib.getExe jq;
                      mako = mako;
                      ncmpcpp = lib.getExe ncmpcpp;
                      newt = newt;
                      notify-send = lib.getExe libnotify;
                      slurp = lib.getExe slurp;
                      swappy = lib.getExe swappy;
                      sway = sway;
                      swaync = lib.getExe swaynotificationcenter;
                      tesseract = lib.getExe tesseract;
                      tmux = lib.getExe tmux;
                      trans = lib.getExe translate-shell;
                      wl_clipboard = wl-clipboard;
                      wofi = lib.getExe wofi;
                      wtype = lib.getExe wtype;
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
}
