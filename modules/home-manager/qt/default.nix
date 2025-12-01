{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager.qt;
  shared = ''
    custom_palette=false
    icon_theme=${config.stylix.iconTheme.dark}
    standard_dialogs=xdgdesktopportal
    style=kvantum-dark

    [Fonts]
    fixed="${config.stylix.fonts.sansSerif.name},${builtins.toString config.stylix.fonts.sizes.applications},-1,5,57,0,0,0,0,0,Regular"
    general="${config.stylix.fonts.sansSerif.name},${builtins.toString config.stylix.fonts.sizes.applications},-1,5,57,0,0,0,0,0,Regular"
  '';
in
{
  options.moduleopts.home-manager.qt = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "qt5 and qt6";
    };
  };
  config = lib.mkIf cfg.enable {
    xdg.configFile = lib.mkMerge [
      {
        "qt5ct/qt5ct.conf".text = ''
          [Appearance]
          color_scheme_path=${pkgs.libsForQt5.qt5ct}/share/qt5ct/colors/airy.conf
        ''
        + shared;
      }
      {
        "qt6ct/qt6ct.conf".text = ''
          [Appearance]
          color_scheme_path=${pkgs.kdePackages.qt6ct}/share/qt6ct/colors/airy.conf
        ''
        + shared;
      }
    ];
  };
}
