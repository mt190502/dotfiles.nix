{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  ########################################
  #
  ## Home Manager Required Variables
  #
  ########################################
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  ########################################
  #
  ## Packages
  #
  ########################################
  home.packages =
    with pkgs;
    [
      #~ custom ~#
      inputs.self.packages."${pkgs.system}".recidia-audio-visualizer
      inputs.self.packages."${pkgs.system}".zmem
      inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd

      #~ fonts ~#
      cantarell-fonts
      cascadia-code
      dejavu_fonts
      fira-code
      hack-font
      jetbrains-mono
      nerd-fonts.droid-sans-mono
      nerd-fonts.iosevka
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-emoji
      noto-fonts-extra

      #~ packages ~#
      _1password-cli
      adw-gtk3
      alacritty-theme
      android-tools
      aria2
      bat
      bat-extras.batman
      bc
      btop
      cliphist
      fastfetch
      fd
      ffmpegthumbnailer
      gcolor3
      gnome-icon-theme
      gnome-tweaks
      grc
      grim
      heimdall
      hicolor-icon-theme
      imagemagick
      kdePackages.dolphin-plugins
      kdePackages.ffmpegthumbs
      kdePackages.kdegraphics-thumbnailers
      kdePackages.qtstyleplugin-kvantum
      kdePackages.qtsvg
      kdePackages.qtwayland
      libsForQt5.qtstyleplugin-kvantum
      lsd
      mpc
      nvtopPackages.full
      nwg-look
      ocs-url
      pavucontrol
      pipes-rs
      playerctl
      pulseaudio
      r2modman
      rclone
      ripgrep-all
      rnnoise-plugin
      rsync
      scrcpy
      slurp
      swappy
      swaybg
      swayidle
      system-config-printer
      tesseract
      tmux
      translate-shell
      trash-cli
      tree
      unrar
      unzip
      wl-clipboard
      wlr-randr
      wlroots_0_17
      wlsunset
      wtype
      ydotool
      yt-dlp
    ]
    ++ (lib.mapAttrsToList
      (
        file: _:
        let
          name = builtins.match ''(.*)[[:space:]]*name[[:space:]]*=[[:space:]]*"([a-zA-Z0-9-]+)"(.*)'' (
            builtins.readFile (inputs.self + "/modules/home-manager/wrapped/${file}")
          );
        in
        if name == null then name else config.wrapped.${builtins.elemAt name 1}
      )
      (
        lib.filterAttrs (n: _: n != "default.nix") (
          builtins.readDir (inputs.self + "/modules/home-manager/wrapped")
        )
      )
    );

  ########################################
  #
  ## Module Configurations
  #
  ########################################
  #~ custom modules ~#
  moduleopts.home-manager = {
    preferred = {
      file-manager = "dolphin";
      lock-app = "swaylock";
      menu = "wofi";
      notifier = "swaync";
      terminal = "alacritty";
      wm = "sway";
    };
    alacritty.theme = "hyper";
    easyeffects.enable = false;
    flatpak.enable = true;
    gtk.enable = true;
    kde.enable = true;
    nextcloud-client.enable = false;
    qt.enable = true;
    waybar.weather_location = "Istanbul";
  };

  #~ systemd ~#
  xdg.configFile."user-tmpfiles.d/home-manager.conf" = {
    text = ''
      L %t/discord-ipc-0 - - - - .flatpak/dev.vencord.Vesktop/xdg-run/discord-ipc-0
      L %t/app/com.discordapp.Discord/discord-ipc-0 - - - - %t/.flatpak/dev.vencord.Vesktop/xdg-run/discord-ipc-0
    '';
    onChange = "${pkgs.systemd}/bin/systemd-tmpfiles --user --create";
  };

  #~ xdg ~#
  xdg.mime.enable = true;

  ########################################
  #
  ## Variables
  #
  ########################################
  home.sessionVariables = {
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
    EDITOR = "vim";
    GTK_USE_PORTAL = "1";
    SYSTEMD_EDITOR = "vim";
    WLR_DRM_NO_ATOMIC = "1";
  };

  ########################################
  #
  ## Other Configurations
  #
  ########################################
  home.activation = { };
  imports =
    lib.map (p: ./. + "/${p}") (lib.remove "default.nix" (lib.attrNames (builtins.readDir ./.)))
    ++ [ inputs.self.homeManagerModules.mt190502 ];
}
