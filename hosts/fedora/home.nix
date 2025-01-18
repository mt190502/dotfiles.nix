{
  config,
  pkgs,
  lib,
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
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  nixGL.packages = inputs.nixgl.packages;

  ########################################
  #
  ## Packages
  #
  ########################################
  home.packages = with pkgs; [
    alacritty-theme
    ansible
    aria2
    bat-extras.batman
    bat
    binwalk
    btop
    bun
    cliphist
    delta
    gcolor3
    go
    grim
    hugo
    hyperfine
    iftop
    (config.lib.nixGL.wrap imagemagick)
    iosevka
    iperf
    jq
    k9s
    kubectl
    lxappearance
    minikube
    nixd
    nixfmt-classic
    nmap
    nvtopPackages.amd
    postgresql_17
    scrcpy
    shellcheck
    slurp
    swappy
    swaybg
    swayidle
    tesseract
    translate-shell
    tmux
    vscode
    (config.lib.nixGL.wrap wdisplays)
    wl-clipboard
    wlroots_0_18
    wlr-randr
    wlsunset
    wpgtk
    wtype
    ydotool
    yq
    yt-dlp
    zola
  ];

  ########################################
  #
  ## Options
  #
  ########################################
  nix.registry = lib.mapAttrs (_: value: { flake = value; }) inputs; # ~ for nix stable channel
  nixpkgs.config = {
    allowUnfree = true;
  }; # ~ for vscode

  #~ packages ~#
  pkgconfig = {
    alacritty = {
      enable = true;
      theme = "hyper";
    };
    fastfetch.enable = true;
    fish.enable = true;
    mako.enable = true;
    mangohud.enable = true;
    mpv.enable = true;
    swappy.enable = true;
    sway.enable = true;
    swaylock.enable = true;
    swaynag.enable = true;
    tmux.enable = true;
    waybar.enable = true;
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
    ./mako # Mako Notification Daemon Configuration
    ./mangohud # MangoHud Configuration
    ./mpv # MPV Configuration
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
    postInstall = "	$SHELL -c \"fisher install ilancosman/tide\" &>/dev/null\n	$SHELL -c \"tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Dotted --prompt_connection_andor_frame_color=Lightest --prompt_spacing=Sparse --icons='Many icons' --transient=Yes\" &>/dev/null\n";
  };
}
