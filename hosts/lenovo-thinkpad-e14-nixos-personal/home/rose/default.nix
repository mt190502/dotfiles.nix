{ lib, ... }:

{
  ########################################
  #
  ## Module Configurations
  #
  ########################################
  #~ custom modules ~#
  # waybar.enableLaptopOpts = true;

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
