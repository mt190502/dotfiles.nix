{ pkgs, pkgs-unstable, ... }:

{
  programs.home-manager.enable = true;
  home = {
    ########################################
    #
    ## Home Manager Required Variables
    #
    ########################################
    stateVersion = "25.11";
    username = "rose";

    ########################################
    #
    ## Packages
    #
    ########################################
    packages =
      with pkgs;
      [
        #~ packages ~#
        aria2
        btop
        git
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
    ## Variables
    #
    ########################################
    sessionVariables = {
      ##############################
      ## SYSTEM
      ##############################
      EDITOR = "vim";
    };
  };

  ########################################
  #
  ## Module Configurations
  #
  ########################################
  # programs.git.settings = { };
}
