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
    lock-app = lib.mkOption {
      type = lib.types.enum [
        "swaylock"
        "hyprlock"
      ];
      default = "swaylock";
      description = "Preferred screen locker: swaylock or hyprlock";
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
    mediaplayer = lib.mkOption {
      type = lib.types.enum [
        "ncmpcpp"
        "rmpc"
        "none"
      ];
      default = "none";
      description = "Preferred media player: ncmpcpp, rmpc, or none";
    };
    weatherLocation = lib.mkOption {
      type = lib.types.str;
      default = "Istanbul";
      description = "Location for weather display";
    };
    wm = lib.mkOption {
      type = lib.types.enum [
        "sway"
        "hyprland"
      ];
      default = "sway";
      description = "Preferred window manager: sway or hyprland";
    };
  };
}
