{
  inputs,
  lib,
  ...
}:

{
  ########################################
  #
  ## Home Manager Required Variables
  #
  ########################################
  home.username = "taha";

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
  moduleopts.home-manager = { };

  ########################################
  #
  ## Custom Modules
  #
  ########################################
  imports =
    lib.map (p: ./. + "/${p}") (
      builtins.filter (p: !(p == "default.nix" || lib.hasSuffix ".txt" p)) (
        lib.attrNames (builtins.readDir ./.)
      )
    )
    ++ [
      inputs.self.homeManagerModules.mt190502
    ];
}
