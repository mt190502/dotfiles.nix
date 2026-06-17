{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  options = {
    fontcfg = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = rec {
        monospace = {
          name = "MesloLGS NF";
          package = pkgs.meslo-lgs-nf;
        };
        sansSerif = {
          name = "Ubuntu Nerd Font Medium";
          package = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".ubuntu-fonts-google;
        };
        serif = sansSerif;
        sizes = {
          applications = 10;
          terminal = 9;
        };
      };
      description = "Centralized font configuration definitions";
    };
    cursorcfg = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {
        name = "Adwaita";
        size = 16;
        package = pkgs.adwaita-icon-theme;
      };
      description = "Centralized cursor theme configuration definitions";
    };
    iconthemecfg = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {
        dark = "Papirus-Dark";
        light = "Papirus-Light";
        package = pkgs.papirus-icon-theme;
      };
      description = "Centralized icon theme configuration definitions";
    };
  };
}
