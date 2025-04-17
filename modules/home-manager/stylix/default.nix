{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

{
  imports = [ inputs.stylix.homeManagerModules.stylix ];

  options.colors = {
    activeColor = lib.mkOption {
      default = config.lib.stylix.colors.withHashtag.base02;
      type = lib.types.str;
    };
    backgroundColor = lib.mkOption {
      default = config.lib.stylix.colors.withHashtag.base00;
      type = lib.types.str;
    };
    inactiveColor = lib.mkOption {
      default = config.lib.stylix.colors.withHashtag.base00;
      type = lib.types.str;
    };
    inactiveColor2 = lib.mkOption {
      default = config.lib.stylix.colors.withHashtag.base01;
      type = lib.types.str;
    };
    urgentColor = lib.mkOption {
      default = "#FF0000";
      type = lib.types.str;
    };
    textColor = lib.mkOption {
      default = config.lib.stylix.colors.withHashtag.base05;
      type = lib.types.str;
    };
  };

  config.stylix = {
    enable = true;
    # autoEnable = false;
    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 16;
    };
    fonts = {
      monospace = {
        name = "MesloLGS NF";
        package = pkgs.meslo-lgs-nf;
      };
      sansSerif = {
        name = "Ubuntu Nerd Font Medium";
        package = inputs.self.packages."${pkgs.system}".ubuntu-fonts-google;
      };
      serif = {
        name = "Ubuntu Nerd Font Medium";
        package = inputs.self.packages."${pkgs.system}".ubuntu-fonts-google;
      };
      sizes = {
        applications = 10;
        terminal = 9;
      };
    };
    iconTheme = {
      enable = true;
      package = pkgs.flat-remix-icon-theme;
      light = "Flat-Remix-Blue-Light";
      dark = "Flat-Remix-Blue-Dark";
    };
    image = inputs.self + /assets/wallpaper;
    polarity = "dark";
    targets = {
      alacritty.enable = false;
      mako.enable = false;
      mangohud.enable = false;
      gtk.enable = false;
      k9s.enable = false;
      kde.enable = false;
      neovim.enable = false;
      nixvim.enable = false;
      qt.enable = false;
      sway.enable = false;
      swaylock.enable = false;
      swaync.enable = false;
      waybar.enable = false;
      wofi.enable = false;
    };
  };
}
