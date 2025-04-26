{
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.stylix.homeManagerModules.stylix ];

  config.stylix = {
    enable = true;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
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
    image = ../../../assets/wallpaper;
    polarity = "dark";
    targets = {
      alacritty.enable = false;
      mangohud.enable = false;
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
