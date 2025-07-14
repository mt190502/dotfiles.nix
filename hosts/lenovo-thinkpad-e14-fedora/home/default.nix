{ inputs, lib, ... }:

{
  ########################################
  #
  ## Home Manager Required Variables
  #
  ########################################
  home.username = "fedora";
  home.homeDirectory = "/home/fedora";
  nixpkgs.config.allowUnfree = true;
  nixGL.packages = inputs.nixgl.packages;
  wrapped.mode = "nixGL";

  ########################################
  #
  ## Packages
  #
  ########################################
  #~ home.packages ~#
  home.packages = [ ];

  ########################################
  #
  ## Module Configurations
  #
  ########################################
  #~ custom modules ~#
  moduleopts.home-manager = {
    flatpak.enable = true;
    gnome-keyring.enable = false; # I'm using keyring in system because of pam issues
    gtk.enable = true;
    kde.enable = true;
    onepassword-integration.enable = true;
    prefered-lock-app = "swaylock";
    prefered-wm = "sway";
    qt.enable = true;
    waybar.enableLaptopOpts = true;
  };

  ########################################
  #
  ## Custom Modules
  #
  ########################################
  imports = lib.map (p: ./. + "/${p}") (
    builtins.filter (p: !(p == "default.nix" || lib.hasSuffix ".txt" p)) (
      lib.attrNames (builtins.readDir ./.)
    )
  );
}
