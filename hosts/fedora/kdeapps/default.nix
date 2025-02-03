{ config, pkgs, ... }:

{
  xdg.configFile."menus/applications.menu".text =
    builtins.readFile "${pkgs.libsForQt5.kservice}/etc/xdg/menus/applications.menu"; # ~ https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/7
  xdg.configFile."kdeglobals".text = ''
    [General]
    AccentColor=61,174,233
    ColorScheme=Kvantum
    ColorSchemeHash=d6c2df0966578859e7aa68d5591d7e3f0cfa19bc
    LastUsedCustomAccentColor=61,174,233
    XftAntialias=true
    XftHintStyle=hintslight
    XftSubPixel=rgb
    fixed=${config.stylix.fonts.monospace.name},${builtins.toString config.stylix.fonts.sizes.applications},-1,5,400,0,0,0,0,0,0,0,0,0,0,1
    font=${config.stylix.fonts.sansSerif.name},${builtins.toString config.stylix.fonts.sizes.applications},-1,5,500,0,0,0,0,0,0,0,0,0,0,1,Regular
    menuFont=${config.stylix.fonts.sansSerif.name},${builtins.toString config.stylix.fonts.sizes.applications},-1,5,500,0,0,0,0,0,0,0,0,0,0,1,Regular
    smallestReadableFont=${config.stylix.fonts.sansSerif.name},8,-1,5,500,0,0,0,0,0,0,0,0,0,0,1,Regular
    toolBarFont=${config.stylix.fonts.sansSerif.name},${builtins.toString config.stylix.fonts.sizes.applications},-1,5,500,0,0,0,0,0,0,0,0,0,0,1,Regular

    [Icons]
    Theme=${config.stylix.iconTheme.dark}

    [KDE]
    LookAndFeelPackage=org.kde.breezedark.desktop
    ShowDeleteCommand=true
    widgetStyle=kvantum

    [KFileDialog Settings]
    Allow Expansion=false
    Automatically select filename extension=true
    Breadcrumb Navigation=true
    Decoration position=2
    LocationCombo Completionmode=5
    PathCombo Completionmode=5
    Show Bookmarks=false
    Show Full Path=false
    Show Inline Previews=true
    Show Preview=false
    Show Speedbar=true
    Show hidden files=false
    Sort by=Name
    Sort directories first=true
    Sort hidden files last=false
    Sort reversed=false
    Speedbar Width=103
    View Style=DetailTree

    [PreviewSettings]
    EnableRemoteFolderThumbnail=false
    MaximumRemoteSize=0

    [WM]
    activeBackground=61,61,62
    activeBlend=61,61,62
    activeFont=${config.stylix.fonts.sansSerif.name},${builtins.toString config.stylix.fonts.sizes.applications},-1,5,500,0,0,0,0,0,0,0,0,0,0,1,Regular
    activeForeground=255,255,255
    inactiveBackground=61,61,62
    inactiveBlend=61,61,62
    inactiveForeground=155,155,155
  '';
}
