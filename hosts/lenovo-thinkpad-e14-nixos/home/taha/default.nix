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
  home.homeDirectory = "/home/taha";

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
    gtk.enable = true;
    kde.enable = true;
    preferred-lock-app = "gtklock";
    preferred-wm = "sway";
    qt.enable = true;
    vicinae.enable = false;
    waybar.enableLaptopOpts = true;
  };

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
