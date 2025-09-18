{ lib, ... }:

{
  options.moduleopts.home-manager = {
    preferred-wm = lib.mkOption {
      type = lib.types.enum [
        "sway"
        "hyprland"
        "none"
      ];
      default = "none";
      description = "Preferred window manager";
    };
    preferred-lock-app = lib.mkOption {
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
