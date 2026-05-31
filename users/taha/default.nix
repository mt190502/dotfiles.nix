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
    username = "taha";

    ########################################
    #
    ## Packages
    #
    ########################################
    packages =
      with pkgs;
      [
        #~ packages ~#
        android-tools
        aria2
        bat
        bat-extras.batman
        bc
        btop
        fd
        git
        grc
        heimdall
        imagemagick
        lsd
        mpc
        pipes-rs
        r2modman
        rclone
        ripgrep-all
        rsync
        scrcpy
        tesseract
        tmux
        translate-shell
        trash-cli
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
  programs = {
    git.settings = rec {
      user = {
        name = "Taha";
        email = "mt190502@mtaha.dev";
        signingKey = signing.key;
      };
      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVyQNBWyCGvlRlqEh/3Ga6CDF01MZo6Jj15mjqHzPFD";
        format = "ssh";
      };
    };
    ssh.settings = {
      "envs" = {
        host = "envs";
        hostname = "envs.net";
        user = "mt190502";
      };
    };
  };
}
