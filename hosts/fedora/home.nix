{
  config,
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
  home.username = "fedora";
  home.homeDirectory = "/home/fedora";
  home.stateVersion = "25.05";
  nixGL.packages = inputs.nixgl.packages;
  programs.home-manager.enable = true;

  ########################################
  #
  ## Packages
  #
  ########################################
  home.packages = with pkgs; [
    #~ wrapped packages ~#
    config.wrappedPkgs.alacritty
    config.wrappedPkgs.dolphin
    config.wrappedPkgs.flameshot
    config.wrappedPkgs.imagemagick
    config.wrappedPkgs.nextcloud-client
    config.wrappedPkgs.nwg-displays
    config.wrappedPkgs.onepassword-gui
    config.wrappedPkgs.qt5ct
    config.wrappedPkgs.qt6ct
    config.wrappedPkgs.vscode

    #~ standard packages ~#
    _1password-cli
    adw-gtk3
    alacritty-theme
    ansible
    aria2
    bat
    bat-extras.batman
    binwalk
    btop
    bun
    cliphist
    delta
    gcolor3
    go
    grc
    grim
    hack-font
    hugo
    hyperfine
    iftop
    iosevka
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
    libsForQt5.qtstyleplugin-kvantum
    minikube
    minio-client
    nixd
    nixfmt-classic
    nmap
    nvtopPackages.amd
    nwg-look
    pavucontrol
    postgresql_17
    scrcpy
    shellcheck
    slurp
    swappy
    swaybg
    swayidle
    tesseract
    tmux
    translate-shell
    ubuntu_font_family
    wl-clipboard
    wlr-randr
    wlroots_0_17
    wlsunset
    wpgtk
    wtype
    ydotool
    yq
    yt-dlp
    zola
  ];

  services.flatpak.enable = true;
  services.flatpak.packages = [
    "ca.desrt.dconf-editor"
    "com.belmoussaoui.ashpd.demo"
    "com.github.libresprite.LibreSprite"
    "com.github.tchx84.Flatseal"
    "com.obsproject.Studio"
    "com.stremio.Stremio"
    "com.usebottles.bottles"
    "com.valvesoftware.Steam"
    "com.vivaldi.Vivaldi"
    "dev.vencord.Vesktop"
    "io.github._0xzer0x.qurancompanion"
    "io.github.mrvladus.List"
    "io.github.ungoogled_software.ungoogled_chromium"
    "io.gitlab.librewolf-community"
    "md.obsidian.Obsidian"
    "net.davidotek.pupgui2"
    "org.audacityteam.Audacity"
    "org.filezillaproject.Filezilla"
    "org.gimp.GIMP"
    "org.gnome.Calculator"
    "org.gnome.Calendar"
    "org.gnome.FileRoller"
    "org.gnome.Loupe"
    "org.gnome.TextEditor"
    "org.gnome.clocks"
    "org.gnome.seahorse.Application"
    "org.inkscape.Inkscape"
    "org.kde.krita"
    "org.kde.kruler"
    "org.kde.KStyle.Kvantum/x86_64/5.15"
    "org.kde.KStyle.Kvantum/x86_64/6.6"
    "org.kde.okular"
    "org.libreoffice.LibreOffice"
    "org.onlyoffice.desktopeditors"
    "org.prismlauncher.PrismLauncher"
    "org.qbittorrent.qBittorrent"
    "org.remmina.Remmina"
    "org.signal.Signal"
    "org.telegram.desktop"
    "org.texstudio.TeXstudio"
    "org.upscayl.Upscayl"
  ];

  ########################################
  #
  ## Options
  #
  ########################################
  # nix.registry = lib.mapAttrs (_: value: { flake = value; }) inputs; # ~ for nix stable channel
  nixpkgs.config.allowUnfree = true; # ~ for vscode and other non-free packages

  #~ services ~#
  services = {
    kdeconnect = {
      enable = true;
      package = config.wrappedPkgs.kdeconnect;
      indicator = true;
    };
  };

  #~ packages ~#
  pkgconfig = {
    alacritty = {
      theme = "hyper";
    };
    waybar = {
      weather_location = "Istanbul";
    };
  };

  #~ colors ~#
  colors = {
    activeColor = config.lib.stylix.colors.withHashtag.base02;
    backgroundColor = config.lib.stylix.colors.withHashtag.base00;
    inactiveColor = config.lib.stylix.colors.withHashtag.base0F;
    inactiveColor2 = config.lib.stylix.colors.withHashtag.base0D;
    urgentColor = "#FF0000";
    textColor = config.lib.stylix.colors.withHashtag.base07;
  };

  #~ xdg ~#
  xdg.mime.enable = true;

  ########################################
  #
  ## Source Files
  #
  ########################################
  home.file = { };

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
    QT_PLUGIN_PATH = "$HOME/.local/lib64/plugins:$HOME/.local/lib/plugins:/usr/local/lib64/plugins:/usr/local/lib/plugins:$HOME/.local/lib64/qt5/plugins:$HOME/.local/lib/qt5/plugins:/usr/local/lib64/qt5/plugins:/usr/local/lib/qt5/plugins:$QT_PLUGIN_PATH";
    QML_IMPORT_PATH = "$HOME/.local/lib64/qml:$HOME/.local/lib/qml:/usr/local/lib64/qml:/usr/local/lib/qml:$QML_IMPORT_PATH";
    QML2_IMPORT_PATH = "$HOME/.local/lib64/qml:$HOME/.local/lib/qml:/usr/local/lib64/qml:/usr/local/lib/qml:$QML2_IMPORT_PATH";
    QT_QPA_PLATFORM = "wayland";
    #QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "kvantum";

    ##############################
    ## SYSTEM
    ##############################
    LD_LIBRARY_PATH = "$HOME/.local/lib64:$HOME/.local/lib:$HOME/.nix-profile/lib64:$HOME/.nix-profile/lib:/usr/local/lib64:/usr/local/lib";
    XDG_DATA_DIRS = "$HOME/.local/share/flatpak/exports/share:$HOME/.local/share:$HOME/.nix-profile/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:$XDG_DATA_DIRS";
    PATH = "$HOME/.local/share/JetBrains/Toolbox/scripts:$HOME/scripts:/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH";
    NIX_PATH = "$HOME/.local/state/nix/profiles/channels";
    XDG_CURRENT_DESKTOP = "sway";
    GTK_USE_PORTAL = "1";
    EDITOR = "vim";
    SYSTEMD_EDITOR = "vim";
  };

  ########################################
  #
  ## Program Configurations and Imports
  #
  ########################################
  imports = [
    ./1password # 1Password Configuration
    ./alacritty # Alacritty Terminal Configuration
    ./fastfetch # Fastfetch Configuration
    ./fish # Fish Shell Configuration
    ./flatpak # Flatpak Configuration
    ./fontconfig # Fontconfig Configuration
    ./kdeapps # KDE Applications Configuration
    ./mako # Mako Notification Daemon Configuration
    ./mangohud # MangoHud Configuration
    ./mpv # MPV Configuration
    ./nextcloud # Nextcloud Client
    ./packages # Custom packages
    ./qt # QT Configuration
    ./stylix # Stylix Configuration
    ./swappy # Swappy Configuration
    ./sway # Sway Window Manager Configuration
    ./swaylock # Swaylock Configuration
    ./swaynag # Swaynag Configuration
    ./swaync # Sway Notification Center Configuration
    ./tmux # Tmux Configuration
    ./waybar # Waybar Configuration
    ./wofi # Wofi Configuration
  ];

  ########################################
  #
  ## Home Activation
  #
  ########################################
  home.activation = {
    postInstall = ''
      $SHELL -c "fisher install ilancosman/tide" &>/dev/null
      $SHELL -c "tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Dotted --prompt_connection_andor_frame_color=Lightest --prompt_spacing=Sparse --icons='Many icons' --transient=Yes" &>/dev/null
    '';
  };
}
