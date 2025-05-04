{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wrapped;
  inherit (lib.types) package;
in
{
  options.wrapped = {
    enable = lib.mkEnableOption "wrapped packages";
    alacritty = lib.mkOption {
      default = pkgs.alacritty;
      type = package;
    };
    dolphin = lib.mkOption {
      default = pkgs.kdePackages.dolphin;
      type = package;
    };
    flameshot = lib.mkOption {
      default = pkgs.flameshot;
      type = package;
    };
    hyprland = lib.mkOption {
      default = pkgs.hyprland;
      type = package;
    };
    imagemagick = lib.mkOption {
      default = pkgs.imagemagick;
      type = package;
    };
    imv = lib.mkOption {
      default = pkgs.imv;
      type = package;
    };
    jetbrains-toolbox = lib.mkOption {
      default = pkgs.jetbrains-toolbox;
      type = package;
    };
    kdeconnect = lib.mkOption {
      default = pkgs.kdePackages.kdeconnect-kde;
      type = package;
    };
    mpd = lib.mkOption {
      default = pkgs.mpd;
      type = package;
    };
    mpv = lib.mkOption {
      default = pkgs.mpv;
      type = package;
    };
    neovide = lib.mkOption {
      default = pkgs.neovide;
      type = package;
    };
    nextcloud-client = lib.mkOption {
      default = pkgs.nextcloud-client;
      type = package;
    };
    nwg-displays = lib.mkOption {
      default = pkgs.nwg-displays;
      type = package;
    };
    pcmanfm-qt = lib.mkOption {
      default = pkgs.pcmanfm-qt;
      type = package;
    };
    qt5ct = lib.mkOption {
      default = pkgs.libsForQt5.qt5ct;
      type = package;
    };
    qt6ct = lib.mkOption {
      default = pkgs.kdePackages.qt6ct;
      type = package;
    };
    sway = lib.mkOption {
      default = pkgs.swayfx;
      type = package;
    };
    vscode = lib.mkOption {
      default = pkgs.vscode;
      type = package;
    };
    waybar = lib.mkOption {
      default = pkgs.waybar;
      type = package;
    };
  };

  config = lib.mkIf cfg.enable {
    wrapped =
      let
        wrapperNames = builtins.attrNames (builtins.removeAttrs cfg [ "enable" ]);
        importWrapper = name: import ./${name}.nix { inherit config pkgs; };
      in
      builtins.listToAttrs (
        map (name: {
          inherit name;
          value = importWrapper name;
        }) wrapperNames
      );
  };
}
