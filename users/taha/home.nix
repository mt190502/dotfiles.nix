{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  arch = pkgs.stdenv.hostPlatform.system;
in
{
  home = {
    ########################################
    #
    ## Home Manager Required Variables
    #
    ########################################
    homeDirectory = "/home/taha";

    ########################################
    #
    ## Packages
    #
    ########################################
    packages = [
      inputs.zmem.packages.${arch}.zmem
    ]
    ++ (with inputs.self.packages.${arch}; [
      ark
      dolphin
      flameshot
      harbor
      jetbrains-toolbox
      okular
    ])
    ++ (with pkgs; [
      #~ fonts ~#
      cantarell-fonts
      cascadia-code
      dejavu_fonts
      fira-code
      hack-font
      jetbrains-mono
      meslo-lgs-nf
      nerd-fonts.droid-sans-mono
      nerd-fonts.iosevka
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      #~ packages ~#
      adw-gtk3
      audacity
      bottles
      ffmpegthumbnailer
      gcolor3
      gnome-calculator
      gnome-clocks
      gnome-icon-theme
      gnome-tweaks
      handbrake
      hicolor-icon-theme
      imagemagick
      kdePackages.dolphin-plugins
      kdePackages.ffmpegthumbs
      kdePackages.kdegraphics-thumbnailers
      kdePackages.kruler
      kdePackages.qt6ct
      kdePackages.qtstyleplugin-kvantum
      kdePackages.qtsvg
      kdePackages.qtwayland
      libsForQt5.qt5ct
      libsForQt5.qtstyleplugin-kvantum
      nvtopPackages.full
      nwg-look
      ocs-url
      picard
      signal-desktop
      slurp
      system-config-printer
      telegram-desktop
      wl-clipboard
      wlr-randr
      wtype
      ydotool
    ])
    ++ (with pkgs-unstable; [
      equibop
      prismlauncher
      slack
    ]);

    ########################################
    #
    ## Variables
    #
    ########################################
    sessionVariables = {
      ##############################
      ## FIREFOX
      ##############################
      MOZ_ENABLE_WAYLAND = "1";

      ##############################
      ## FREETYPE
      ##############################
      FREETYPE_PROPERTIES = "truetype:interpreter-version=40";

      ##############################
      ## QT
      ##############################
      QT_QPA_PLATFORM = "wayland";
      # QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_STYLE_OVERRIDE = "kvantum";

      ##############################
      ## SYSTEM
      ##############################
      GTK_USE_PORTAL = "1";
      SYSTEMD_EDITOR = "vim";
      WLR_DRM_NO_ATOMIC = "1";
    };
  };
  ########################################
  #
  ## Other Configurations
  #
  ########################################
  #~ xdg ~#
  xdg.mime.enable = true;
  imports = [ ./default.nix ];
}
