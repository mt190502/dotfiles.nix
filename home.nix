{ pkgs, ... }:

{
  ########################################
  #
  ## Home Manager Required Variables
  #
  ########################################
  home.username = "fedora";
  home.homeDirectory = "/home/fedora";
  home.stateVersion = "24.11";

  ########################################
  #
  ## Packages
  #
  ########################################
  home.packages = with pkgs; [
    alacritty
    bat-extras.batman
    bat
    fastfetch
    grim
    k9s
    kubectl
    mako
    mangohud
    nixd
    nixfmt-classic
    postgresql_17
    scrcpy
    slurp
    swappy
    sway
    swaylock
    tmux
    waybar
    wofi
    wpgtk
  ];

  ########################################
  #
  ## Options
  #
  ########################################
  alacritty = {
    enable = true;
    theme = "vibrant-ink";
  };
  fastfetch = { enable = true; };
  fish = { enable = true; };
  mako = { enable = true; };
  mangohud = { enable = true; };
  mpv = { enable = true; };
  swappy = { enable = true; };
  sway = { enable = true; };
  swaylock = { enable = true; };
  swaynag = { enable = true; };
  tmux = { enable = true; };
  waybar = { enable = true; };
  wofi = { enable = true; };
  wpg = { enable = true; };

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
    ./Mangohud # MangoHud Configuration
    ./mpv # MPV Configuration
    ./swappy # Swappy Configuration
    ./sway # Sway Window Manager Configuration
    ./swaylock # Swaylock Configuration
    ./swaynag # Swaynag Configuration
    ./tmux # Tmux Configuration
    ./waybar # Waybar Configuration
    ./wofi # Wofi Configuration
    ./wpg # Wpg Configuration
  ];

  ########################################
  #
  ## Home Activation
  #
  ########################################
  home.activation = {
    postInstall = ''
      $SHELL -c "fisher install ilancosman/tide" &>/dev/null
    '';
  };
}
