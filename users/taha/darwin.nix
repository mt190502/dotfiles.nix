{ pkgs, ... }:

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
    #~ packages ~#
    android-tools
    aria2
    bat
    bat-extras.batman
    bc
    btop
    fastfetch
    fd
    grc
    heimdall
    lsd
    mpc
    pipes-rs
    rclone
    ripgrep-all
    rsync
    tesseract
    tmux
    translate-shell
    tree
    unrar
    unzip
    yt-dlp
  ];

  ########################################
  #
  ## Module Configurations
  #
  ########################################
  #~ custom modules ~#
  moduleopts.home-manager = {
    alacritty.theme = "hyper";
  };

  ########################################
  #
  ## Variables
  #
  ########################################
  home.sessionVariables = {
    ##############################
    ## SYSTEM
    ##############################
    EDITOR = "vim";
  };

  ########################################
  #
  ## Other Configurations
  #
  ########################################
  home.activation = { };
}
