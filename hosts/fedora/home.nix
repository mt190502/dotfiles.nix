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
  nixGL.packages = inputs.nixgl.packages;

  ########################################
  #
  ## Packages
  #
  ########################################
  home.packages = with pkgs; [
    (config.lib.nixGL.wrap alacritty)
    ansible
    aria2
    bat-extras.batman
    bat
    binwalk
    btop
    delta
    fastfetch
    gcolor3
    grim
    hugo
    hyperfine
    iftop
    (config.lib.nixGL.wrap imv)
    iperf
    k9s
    kubectl
    lxappearance
    mako
    mangohud
    mpv
    nixd
    nixfmt-classic
    nmap
    postgresql_17
    scrcpy
    shellcheck
    slurp
    swappy
    swayidle
    tesseract
    tmux
    vscode
    waybar
    (config.lib.nixGL.wrap wdisplays)
    wl-clipboard
    wlroots_0_18
    wlr-randr
    wlsunset
    wofi
    wpgtk
    wtype
    ydotool
    yt-dlp
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
      theme = "vibrant-ink";
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
  #pkgconfig.wpg       = { enable = false; };

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
  programs.home-manager.enable = true;
  imports = [
    ./alacritty # Alacritty Terminal Configuration
    ./fastfetch # Fastfetch Configuration
    ./fish # Fish Shell Configuration
    ./mako # Mako Notification Daemon Configuration
    ./mangohud # MangoHud Configuration
    ./mpv # MPV Configuration
    ./swappy # Swappy Configuration
    ./sway # Sway Window Manager Configuration
    ./swaylock # Swaylock Configuration
    ./swaynag # Swaynag Configuration
    ./tmux # Tmux Configuration
    ./waybar # Waybar Configuration
    ./wofi # Wofi Configuration
    #./wpg # Wpg Configuration
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
