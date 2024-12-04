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
    k9s
    kubectl
    mako
    mangohud
    nixd
    nixfmt-classic
    postgresql_17
    scrcpy
    swappy
    sway
    swaylock
    tmux
    waybar
    wofi
  ];

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
    ./alacritty/main.nix # Alacritty Terminal Configuration
    ./fastfetch/main.nix # Fastfetch Configuration
    ./fish/main.nix # Fish Shell Configuration
    ./mako/main.nix # Mako Notification Daemon Configuration
    # ./Mangohud/main.nix # MangoHud Configuration
    # ./mpv/main.nix # MPV Configuration
    # ./swappy/main.nix # Swappy Configuration
    # ./sway/main.nix # Sway Window Manager Configuration
    # ./swaylock/main.nix # Swaylock Configuration
    # ./swaynag/main.nix # Swaynag Configuration
    # ./tmux/main.nix # Tmux Configuration
    # ./waybar/main.nix # Waybar Configuration
    # ./wofi/main.nix # Wofi Configuration
  ];

  ########################################
  #
  ## Home Activation
  #
  ########################################
  home.activation = { };
}
