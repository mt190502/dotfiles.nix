{ pkgs, pkgs-unstable, ... }:

{
  ########################################
  #
  ## Home Manager Required Variables
  #
  ########################################
  home.stateVersion = "25.11";
  home.username = "rose";
  programs.home-manager.enable = true;

  ########################################
  #
  ## Packages
  #
  ########################################
  home.packages =
    with pkgs;
    [
      #~ packages ~#
      android-tools
      aria2
      btop
      grc
      heimdall
      imagemagick
      lsd
      rclone
      scrcpy
      tesseract
      tree
      unrar
      unzip
      yt-dlp
    ]
    ++ (with pkgs-unstable; [ ]);

  ########################################
  #
  ## Module Configurations
  #
  ########################################
  # programs.git.settings = { };

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
