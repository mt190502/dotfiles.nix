{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager;
in
{
  options.moduleopts.home-manager.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "hyprland";
    };
  };
  config = lib.mkIf cfg.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = lib.mkIf (cfg.prefered-wm == "hyprland") true;
      package = config.wrapped.hyprland;
      settings = {
        "$mod" = "SUPER_L";
        "$alt" = "ALT";
      };
    };
  };
  imports = lib.map (p: ./config.d + "/${p}") (
    lib.remove "default.nix" (builtins.attrNames (builtins.readDir ./config.d))
  );
}
