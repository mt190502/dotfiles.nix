{ lib, ... }:

{
  home = {
    ########################################
    #
    ## Home Manager Required Variables
    #
    ########################################
    username = lib.mkForce "fedora";
    homeDirectory = lib.mkForce "/home/fedora";

    ########################################
    #
    ## Variables
    #
    ########################################
    sessionVariables = {
      ##############################
      ## LIBVA/VDPAU
      ##############################
      LIBVA_DRIVER_NAME = "iHD";
      VDPAU_DRIVER = "radeonsi";
    };
  };

  ########################################
  #
  ## Module Configurations
  #
  ########################################
  #~ custom modules ~#
  targets.genericLinux.enable = true;

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
