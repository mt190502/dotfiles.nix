{
  config,
  lib,
  pkgs,
  ...
}:

{
  gtk = {
    enable = true;
    cursorTheme = {
      name = config.stylix.cursor.name;
      size = config.stylix.cursor.size;
      package = lib.mkForce config.stylix.cursor.package;
    };
    font = {
      name = config.stylix.fonts.sansSerif.name;
      package = lib.mkForce config.stylix.fonts.sansSerif.package;
    };
    iconTheme = {
      name = config.stylix.iconTheme.dark;
      package = lib.mkForce config.stylix.iconTheme.package;
    };
    # theme = {
    #   name = "adw-gtk3-dark";
    #   package = lib.mkForce pkgs.adw-gtk3;
    # };
  };
}
