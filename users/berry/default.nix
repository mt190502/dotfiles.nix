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
    username = "berry";

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
        lsd
        rclone
        tree
        unrar
        unzip
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

    ########################################
    #
    ## Activations
    #
    ########################################
    activation = { };
  };

  ########################################
  #
  ## Module Configurations
  #
  ########################################
  # programs.git.settings = { };
}
