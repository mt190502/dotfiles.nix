{ config, lib, ... }:

{
  xdg.configFile = lib.mkMerge [
    {
      "qt5ct/qt5ct.conf".text = ''
        [Appearance]
        color_scheme_path=${config.wrappedPkgs.qt5ct}/share/qt5ct/colors/airy.conf

        custom_palette=false
        icon_theme=${config.stylix.cursor.name}
        standard_dialogs=xdgdesktopportal
        style=kvantum-dark

        [Fonts]
        fixed="${config.stylix.fonts.sansSerif.name},${builtins.toString config.stylix.fonts.sizes.applications},-1,5,57,0,0,0,0,0,Regular"
        general="${config.stylix.fonts.sansSerif.name},${builtins.toString config.stylix.fonts.sizes.applications},-1,5,57,0,0,0,0,0,Regular"
      '';
    }
    {
      "qt6ct/qt6ct.conf".text = ''
        [Appearance]
        color_scheme_path=${config.wrappedPkgs.qt6ct}/share/qt6ct/colors/airy.conf

        custom_palette=false
        icon_theme=${config.stylix.iconTheme.dark}
        standard_dialogs=xdgdesktopportal
        style=kvantum-dark

        [Fonts]
        fixed="${config.stylix.fonts.sansSerif.name},${builtins.toString config.stylix.fonts.sizes.applications},-1,5,57,0,0,0,0,0,Regular"
        general="${config.stylix.fonts.sansSerif.name},${builtins.toString config.stylix.fonts.sizes.applications},-1,5,57,0,0,0,0,0,Regular"
      '';
    }
  ];
}
