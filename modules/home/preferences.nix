{ lib, ... }:

{
  options.preferences = {
    bar = lib.mkOption {
      type = lib.types.enum [
        "waybar"
        "none"
      ];
      default = "waybar";
      description = "Preferred status bar: waybar or none";
    };
    desktopenv = lib.mkOption {
      type = lib.types.enum [
        "sway"
        "plasma"
      ];
      default = "sway";
      description = "Preferred window manager: sway or plasma";
    };
    lock-app = lib.mkOption {
      type = lib.types.enum [
        "swaylock"
        "hyprlock"
      ];
      default = "swaylock";
      description = "Preferred screen locker: swaylock or hyprlock";
    };
    mediaplayer = lib.mkOption {
      type = lib.types.enum [
        "ncmpcpp"
        "rmpc"
        "none"
      ];
      default = "none";
      description = "Preferred media player: ncmpcpp, rmpc, or none";
    };
    menu = lib.mkOption {
      type = lib.types.enum [
        "wofi"
        "vicinae"
      ];
      default = "wofi";
      description = "Preferred application launcher: wofi or vicinae";
    };
    notifier = lib.mkOption {
      type = lib.types.enum [
        "swaync"
        "mako"
      ];
      default = "swaync";
      description = "Preferred notification daemon: swaync or mako";
    };
    terminal = lib.mkOption {
      type = lib.types.enum [
        "foot"
        "alacritty"
      ];
      default = "foot";
      description = "Preferred terminal emulator: foot or alacritty";
    };
    weatherLocation = lib.mkOption {
      type = lib.types.str;
      default = "Istanbul";
      description = "Location for weather display";
    };
  };
}
