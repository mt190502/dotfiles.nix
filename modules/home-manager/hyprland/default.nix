{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager;
  is_enabled = if cfg.preferred-wm == "hyprland" then true else false;
in
{
  options.moduleopts.home-manager.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = is_enabled;
      description = "hyprland";
    };
  };
  config = lib.mkIf cfg.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = is_enabled;
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
