{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  ########################################
  #
  ## Home Manager Required Variables
  #
  ########################################
  home.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;

  ########################################
  #
  ## Packages
  #
  ########################################
  home.packages = with pkgs; [
    #~ custom ~#
    inputs.self.packages."${pkgs.system}".zmem
    inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd

    #~ fonts ~#
    cascadia-code
    nerd-fonts.droid-sans-mono
    fira-code
    hack-font
    jetbrains-mono
    nerd-fonts.droid-sans-mono
    nerd-fonts.iosevka
    noto-fonts-color-emoji

    #~ standard packages ~#
    _1password-cli
    adw-gtk3
    alacritty-theme
    android-tools
    ansible
    aria2
    bat
    bat-extras.batman
    bc
    binwalk
    btop
    cliphist
    delta
    direnv
    fastfetch
    ffmpegthumbnailer
    gcolor3
    gdb
    gef
    gnome-icon-theme
    gnome-tweaks
    grc
    grim
    heimdall
    hicolor-icon-theme
    hugo
    hyperfine
    iftop
    imagemagick
    iperf
    jq
    k0sctl
    k9s
    kdePackages.dolphin-plugins
    kdePackages.kdegraphics-thumbnailers
    kdePackages.qtstyleplugin-kvantum
    kdePackages.qtsvg
    kdePackages.qtwayland
    kubectl
    kubernetes-helm
    kubetail
    libsForQt5.qtstyleplugin-kvantum
    lsd
    minikube
    minio-client
    mpc
    netcat
    nixd
    nixfmt-rfc-style
    nmap
    nvtopPackages.full
    nwg-look
    ocs-url
    pavucontrol
    playerctl
    postgresql_17
    pulseaudio
    r2modman
    rnnoise-plugin
    rsync
    scrcpy
    shellcheck
    slurp
    swappy
    swaybg
    swayidle
    system-config-printer
    tesseract
    tmux
    traceroute
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
    yq
    yt-dlp
    zola
  ];

  ########################################
  #
  ## Module Configurations
  #
  ########################################
  #~ custom modules ~#
  moduleopts = {
    alacritty.theme = "hyper";
    easyeffects.enable = false;
    mako.enable = false;
    nextcloud-client.enable = false;
    waybar.weather_location = "Istanbul";
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
    ## LIBVA/VDPAU
    ##############################
    #DRI_PRIME = "1"
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "radeonsi";

    ##############################
    ## FIREFOX
    ##############################
    MOZ_ENABLE_WAYLAND = "1";

    ##############################
    ## FREETYPE
    ##############################
    FREETYPE_PROPERTIES = "truetype:interpreter-version=40";
    #FREETYPE_PROPERTIES = "cff:darkening-parameters=500,550,1000,25,1667,0,2000,0";

    ##############################
    ## QT
    ##############################
    QML_IMPORT_PATH = "$HOME/.local/lib64/qml:$HOME/.local/lib/qml:/usr/local/lib64/qml:/usr/local/lib/qml:$QML_IMPORT_PATH";
    QML2_IMPORT_PATH = "$HOME/.local/lib64/qml:$HOME/.local/lib/qml:/usr/local/lib64/qml:/usr/local/lib/qml:$QML2_IMPORT_PATH";
    QT_PLUGIN_PATH = "$HOME/.local/lib64/plugins:$HOME/.local/lib/plugins:/usr/local/lib64/plugins:/usr/local/lib/plugins:$HOME/.local/lib64/qt5/plugins:$HOME/.local/lib/qt5/plugins:/usr/local/lib64/qt5/plugins:/usr/local/lib/qt5/plugins:$QT_PLUGIN_PATH";
    QT_QPA_PLATFORM = "wayland";
    # QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "kvantum";

    ##############################
    ## SYSTEM
    ##############################
    LD_LIBRARY_PATH = "$HOME/.local/lib64:$HOME/.local/lib:$HOME/.nix-profile/lib64:$HOME/.nix-profile/lib:/usr/local/lib64:/usr/local/lib";
    PATH = "$HOME/.local/share/JetBrains/Toolbox/scripts:$HOME/scripts:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH";
    XDG_DATA_DIRS = "$HOME/.local/share/flatpak/exports/share:$HOME/.local/share:$HOME/.nix-profile/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:$XDG_DATA_DIRS";
    EDITOR = "vim";
    GTK_USE_PORTAL = "1";
    SYSTEMD_EDITOR = "vim";
    XDG_CURRENT_DESKTOP = "sway";
    WLR_DRM_NO_ATOMIC = "1";
  };

  ########################################
  #
  ## Other Configurations
  #
  ########################################
  home.activation = {
    postInstall = ''
      $SHELL -c "fisher install ilancosman/tide" &>/dev/null
      $SHELL -c "tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Dotted --prompt_connection_andor_frame_color=Lightest --prompt_spacing=Sparse --icons='Many icons' --transient=Yes" &>/dev/null
    '';
  };
  imports =
    lib.map (p: ./. + "/${p}") (lib.remove "default.nix" (lib.attrNames (builtins.readDir ./.)))
    ++ [ inputs.self.homeManagerModules.mt190502 ];
}
