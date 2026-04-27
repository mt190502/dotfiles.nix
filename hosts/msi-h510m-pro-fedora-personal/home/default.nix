{ lib, ... }:

{
  ########################################
  #
  ## Home Manager Required Variables
  #
  ########################################
  home.username = lib.mkForce "fedora";
  home.homeDirectory = lib.mkForce "/home/fedora";

  ########################################
  #
  ## Module Configurations
  #
  ########################################
  #~ custom modules ~#
  targets.genericLinux.enable = true;

  ########################################
  #
  ## Variables
  #
  ########################################
  home.sessionVariables = {
    ##############################
    ## LIBVA/VDPAU
    ##############################
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "radeonsi";
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
