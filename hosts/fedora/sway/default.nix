{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.pkgconfig.sway = {
    enable = lib.mkEnableOption "Enable sway window manager configuration.";
  };

  config.wayland.windowManager.sway = {
    enable = config.pkgconfig.sway.enable;
    package = (config.wrappedPkgs.sway);
    checkConfig = false;
    config = {
      modifier = "Mod4";
    };
  };

  config.xdg.configFile = lib.mkIf config.pkgconfig.sway.enable (
    builtins.listToAttrs (
      lib.map (path: {
        name = "sway/scripts.d/${path}";
        value = {
          source = pkgs.substituteAll {
            src = ./scripts.d + "/${path}";
            env = {
              alacritty = config.wrappedPkgs.alacritty;
              cliphist = lib.getExe pkgs.cliphist;
              grim = lib.getExe pkgs.grim;
              imagemagick = config.wrappedPkgs.imagemagick;
              imv = config.wrappedPkgs.imv;
              jq = lib.getExe pkgs.jq;
              mako = pkgs.mako;
              slurp = lib.getExe pkgs.slurp;
              # swaylock = lib.getExe pkgs.swaylock;     # not available in non nixos systems
              swappy = lib.getExe pkgs.swappy;
              sway = config.wrappedPkgs.sway;
              tesseract = lib.getExe pkgs.tesseract;
              tmux = lib.getExe pkgs.tmux;
              trans = lib.getExe pkgs.translate-shell;
              wl_clipboard = pkgs.wl-clipboard;
              wofi = lib.getExe pkgs.wofi;
              wtype = lib.getExe pkgs.wtype;
            };
          };
          executable = true;
        };
      }) (builtins.attrNames (builtins.readDir ./scripts.d))
    )
  );

  imports = [
    ./config.d/colors.nix
    ./config.d/environments.nix
    ./config.d/inputs.nix
    ./config.d/others.nix
    ./config.d/outputs.nix
    ./config.d/settings.nix
    ./config.d/shortcuts.nix
    ./config.d/windowrules.nix
  ];
}
