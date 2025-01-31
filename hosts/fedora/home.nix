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
  programs.home-manager.enable = true;
  nixGL.packages = inputs.nixgl.packages;

  ########################################
  #
  ## Packages
  #
  ########################################
  home.packages = with pkgs; [
    #~ wrapped packages ~#
    (config.lib.nixGL.wrap libsForQt5.qt5ct)
    (config.lib.nixGL.wrap kdePackages.qt6ct)
    (config.lib.nixGL.wrap imagemagick)
    (config.lib.nixGL.wrap nwg-displays)
    config.wrappedPkgs.dolphin
    config.wrappedPkgs.flameshot

    #~ standard packages ~#
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
    kdePackages.kio-fuse
    kdePackages.kio-extras
    kdePackages.konsole
    kdePackages.qtsvg
    kdePackages.qtstyleplugin-kvantum
    kdePackages.qtwayland
    kubectl
    kubernetes-helm
    libsForQt5.qtstyleplugin-kvantum
    minio-client
    minikube
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
    tzdata
    vscode
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
    "com.github.jms55.Sandbox"
    "com.github.libresprite.LibreSprite"
    "com.github.tchx84.Flatseal"
    "com.google.Chrome"
    "com.mattjakeman.ExtensionManager"
    "com.obsproject.Studio"
    "com.raggesilver.BlackBox"
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
    "org.flameshot.Flameshot"
    "org.gimp.GIMP"
    "org.gnome.Calculator"
    "org.gnome.Calendar"
    "org.gnome.Evolution"
    "org.gnome.FileRoller"
    "org.gnome.Loupe"
    "org.gnome.Tetravex"
    "org.gnome.TextEditor"
    "org.gnome.clocks"
    "org.gnome.dspy"
    "org.gnome.seahorse.Application"
    "org.inkscape.Inkscape"
    "org.kde.krita"
    "org.kde.kruler"
    "org.kde.okular"
    "org.libreoffice.LibreOffice"
    "org.mozilla.firefox"
    "org.onlyoffice.desktopeditors"
    "org.prismlauncher.PrismLauncher"
    "org.qbittorrent.qBittorrent"
    "org.remmina.Remmina"
    "org.signal.Signal"
    "org.telegram.desktop"
    "org.texstudio.TeXstudio"
    "org.videolan.VLC"
  ];

  ########################################
  #
  ## Options
  #
  ########################################
  # nix.registry = lib.mapAttrs (_: value: { flake = value; }) inputs; # ~ for nix stable channel
  nixpkgs.config = {
    allowUnfree = true;
  }; # ~ for vscode

  #~ services ~#
  services = {
    kdeconnect = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.kdePackages.kdeconnect-kde;
      indicator = true;
    };
  };

  #~ packages ~#
  pkgconfig = {
    alacritty = {
      enable = true;
      theme = "hyper";
    };
    fastfetch.enable = true;
    fish.enable = true;
    fontconfig.enable = true;
    mako.enable = true;
    mangohud.enable = true;
    mpv.enable = true;
    swappy.enable = true;
    sway.enable = true;
    swaylock.enable = true;
    swaynag.enable = true;
    tmux.enable = true;
    waybar = {
      enable = true;
      weather_location = "Istanbul";
    };
    wofi.enable = true;
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
    EDITOR = "vim";
    SYSTEMD_EDITOR = "vim";
  };

  ########################################
  #
  ## Program Configurations and Imports
  #
  ########################################
  imports = [
    ./alacritty # Alacritty Terminal Configuration
    ./fastfetch # Fastfetch Configuration
    ./fish # Fish Shell Configuration
    ./flatpak # Flatpak Configuration
    ./fontconfig # Fontconfig Configuration
    ./mako # Mako Notification Daemon Configuration
    ./mangohud # MangoHud Configuration
    ./mpv # MPV Configuration
    ./packages # Custom packages
    ./stylix # Stylix Configuration
    ./swappy # Swappy Configuration
    ./sway # Sway Window Manager Configuration
    ./swaylock # Swaylock Configuration
    ./swaynag # Swaynag Configuration
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
