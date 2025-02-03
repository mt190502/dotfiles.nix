{ config, lib, ... }:

{
  options.pkgconfig.qtstyle.enable = lib.mkEnableOption "Enable qt styling";

  config = lib.mkIf config.pkgconfig.qtstyle.enable {
    xdg.configFile = lib.mkMerge [
      {
        "qt5ct/qt5ct.conf".text = ''
          [Appearance]
          color_scheme_path=${config.wrappedPkgs.qt5ct}/share/qt5ct/colors/airy.conf

          custom_palette=false
          icon_theme=Flat-Remix-Blue-Dark
          standard_dialogs=xdgdesktopportal
          style=kvantum-dark

          [Fonts]
          fixed="Ubuntu Medium,9,-1,5,57,0,0,0,0,0,Regular"
          general="Ubuntu Medium,9,-1,5,57,0,0,0,0,0,Regular"
        '';
      }
      {
        "qt6ct/qt6ct.conf".text = ''
          [Appearance]
          color_scheme_path=${config.wrappedPkgs.qt6ct}/share/qt6ct/colors/airy.conf

          custom_palette=false
          icon_theme=Flat-Remix-Blue-Dark
          standard_dialogs=xdgdesktopportal
          style=kvantum-dark

          [Fonts]
          fixed="Ubuntu Medium,9,-1,5,57,0,0,0,0,0,Regular"
          general="Ubuntu Medium,9,-1,5,57,0,0,0,0,0,Regular"
        '';
      }
    ];
  };
}
