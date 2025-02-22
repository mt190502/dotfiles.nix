{ config, pkgs, ... }:

{
  gtk = {
    enable = true;
    cursorTheme = {
      name = config.stylix.cursor.name;
      size = config.stylix.cursor.size;
      package = config.stylix.cursor.package;
    };
    font = {
      name = config.stylix.fonts.sansSerif.name;
      package = config.stylix.fonts.sansSerif.package;
    };
    iconTheme = {
      name = config.stylix.iconTheme.dark;
      package = config.stylix.iconTheme.package;
    };
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
  };
}