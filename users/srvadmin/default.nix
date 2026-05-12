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
    username = "srvadmin";

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
  preferences.desktopenv = "none";
  programs.git.settings = rec {
    user = {
      name = "SrvAdmin";
      email = "srvadmin@mtaha.dev";
      signingKey = signing.key;
    };
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVyQNBWyCGvlRlqEh/3Ga6CDF01MZo6Jj15mjqHzPFD";
      format = "ssh";
    };
  };
}
