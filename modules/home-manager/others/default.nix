{ lib, ... }:

{
  options.moduleopts.home-manager = {
    preffered-wm = lib.mkOption {
      type = lib.types.enum [
        "sway"
        "hyprland"
        "none"
      ];
      default = "none";
      description = "Preferred window manager";
    };
  };
}
