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
    fd
    ffmpegthumbnailer
    gcolor3
    gdb
    gef
    gnome-icon-theme
    gnome-tweaks
    gping
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
    kdePackages.ffmpegthumbs
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
    onefetch
    pavucontrol
    pipes-rs
    playerctl
    postgresql_17
    pulseaudio
    r2modman
    rclone
    ripgrep-all
    rnnoise-plugin
    rsync
    scrcpy
    siege
    shellcheck
    slurp
    strace
    swappy
    swaybg
    swayidle
    system-config-printer
    tesseract
    testssl
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
  moduleopts.home-manager = {
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
