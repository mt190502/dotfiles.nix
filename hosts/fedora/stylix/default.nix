{ pkgs, ... }:

{
  stylix = {
    enable = true;
    # autoEnable = false;

    fonts = {
      monospace = {
        name = "MesloLGS NF";
        package = pkgs.meslo-lgs-nf;
      };
      sansSerif = {
        name = "Ubuntu Medium";
        package = pkgs.ubuntu_font_family;
      };
      serif = {
        name = "Ubuntu Medium";
        package = pkgs.ubuntu_font_family;
      };
      sizes = {
        applications = 10;
        terminal = 9;
      };
    };
    image = ../bin/wallpaper.jpg;

    polarity = "dark";
    targets = {
      alacritty.enable = false;
      mako.enable = false;
      gtk.enable = false;
      kde.enable = false;
      sway.enable = false;
      swaylock.enable = false;
      waybar.enable = false;
      wofi.enable = false;
    };
  };
}
