{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

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
    packages =
      with pkgs;
      [
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
        noto-fonts

        #~ packages ~#
        _1password-cli
        adw-gtk3
        config.wrapped.dolphin
        ffmpegthumbnailer
        gcolor3
        gnome-icon-theme
        gnome-tweaks
        hicolor-icon-theme
        imagemagick
        kdePackages.dolphin-plugins
        kdePackages.ffmpegthumbs
        kdePackages.kdegraphics-thumbnailers
        kdePackages.qt6ct
        kdePackages.qtstyleplugin-kvantum
        kdePackages.qtsvg
        kdePackages.qtwayland
        libsForQt5.qt5ct
        libsForQt5.qtstyleplugin-kvantum
        nvtopPackages.full
        nwg-look
        ocs-url
        slurp
        system-config-printer
        wl-clipboard
        wlr-randr
        wtype
        ydotool
      ]
      ++ (with pkgs-unstable; [ ]);

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

    ########################################
    #
    ## Activations
    #
    ########################################
    activation = { };
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
