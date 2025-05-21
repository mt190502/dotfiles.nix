{ lib, ... }:

{
  options.moduleopts.home-manager = {
    prefered-wm = lib.mkOption {
      type = lib.types.enum [
        "sway"
        "hyprland"
        "none"
      ];
      default = "none";
      description = "Preferred window manager";
    };
    prefered-lock-app = lib.mkOption {
      type = lib.types.enum [
        "swaylock"
        "gtklock"
        "none"
      ];
      default = "none";
      description = "Preferred lock application";
    };
  };
}
