{
  config,
  lib,
  pkgs,
  system,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  home = config.home.homeDirectory;
in
{
  options.moduleopts.home-manager.scripts = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "scripts";
    };
  };
  config = lib.mkIf (cfg.scripts.enable && lib.hasSuffix "linux" system) {
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
                      inherit
                        coreutils
                        imagemagick
                        imv
                        mako
                        newt
                        sway
                        ;
                      alacritty = lib.getExe alacritty;
                      bash = lib.getExe' bash "bash";
                      cliphist = lib.getExe cliphist;
                      grim = lib.getExe grim;
                      jq = lib.getExe jq;
                      lock-screen-function =
                        if cfg.${cfg.preferred.lock-app}.systemd.enable then
                          "${lib.getExe' systemd "systemctl"} --user start session-lock"
                        else if cfg.preferred.lock-app == "swaylock" then
                          "${home}/.config/sway/scripts.d/blurlock"
                        else
                          cfg.preferred.lock-app;
                      ncmpcpp = lib.getExe ncmpcpp;
                      notify-send = lib.getExe libnotify;
                      sh = lib.getExe' bash "sh";
                      slurp = lib.getExe slurp;
                      swappy = lib.getExe swappy;
                      swaync = lib.getExe swaynotificationcenter;
                      tesseract = lib.getExe tesseract;
                      tmux = lib.getExe tmux;
                      trans = lib.getExe translate-shell;
                      wofi = lib.getExe wofi;
                      wtype = lib.getExe wtype;
                      xev = lib.getExe xorg.xev;
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
