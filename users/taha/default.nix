{ pkgs, pkgs-unstable, ... }:

{
  ########################################
  #
  ## Home Manager Required Variables
  #
  ########################################
  home.stateVersion = "25.11";
  home.username = "taha";
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
      bat
      bat-extras.batman
      bc
      btop
      fd
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
  ## Module Configurations
  #
  ########################################
  programs.git.settings = {
    user = {
      name = "Taha";
      email = "mt190502@mtaha.dev";
    };
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVyQNBWyCGvlRlqEh/3Ga6CDF01MZo6Jj15mjqHzPFD";
      format = "ssh";
    };
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
  #  imports = [ inputs.self.homeModules.mt190502 ];
}
