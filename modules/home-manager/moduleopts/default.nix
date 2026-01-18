{ lib, ... }:

{
  options.moduleopts.home-manager = {
    preferred = {
      bar = lib.mkOption {
        type = lib.types.enum [
          "quickshell"
          "waybar"
          "none"
        ];
        default = "none";
        description = "Preferred status bar";
      };
      lock-app = lib.mkOption {
        type = lib.types.enum [
          "swaylock"
          "gtklock"
          "none"
        ];
        default = "none";
        description = "Preferred lock application";
      };
      menu = lib.mkOption {
        type = lib.types.enum [
          "wofi"
          "vicinae"
          "none"
        ];
        default = "none";
        description = "Preferred application menu";
      };
      notifier = lib.mkOption {
        type = lib.types.enum [
          "mako"
          "swaync"
          "none"
        ];
        default = "none";
        description = "Preferred notification daemon";
      };
      terminal = lib.mkOption {
        type = lib.types.enum [
          "alacritty"
          "foot"
          "none"
        ];
        default = "none";
        description = "Preferred terminal emulator";
      };
      wm = lib.mkOption {
        type = lib.types.enum [
          "sway"
          "hyprland"
          "none"
        ];
        default = "none";
        description = "Preferred window manager";
      };
    };
  };
}
