{ pkgs, pkgs-unstable, ... }:

{
  ########################################
  #
  ## Home Manager Required Variables
  #
  ########################################
  home.stateVersion = "25.11";
  home.username = "berry";
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
      aria2
      btop
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
