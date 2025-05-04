{
  config,
  lib,
  pkgs,
  ...
}:

{
  wayland.windowManager.hyprland.settings.env = [
    "$browser,${lib.getExe pkgs.flatpak} run io.gitlab.librewolf-community"
    "$filemanager,${lib.getExe config.wrapped.dolphin}"
    "$mediaplayer,${lib.getExe config.wrapped.mpv}"
    "$menu,${lib.getExe pkgs.wofi} --prompt 'Search Apps' --show drun"
    "$terminal,${lib.getExe config.wrapped.alacritty}"
  ];
}
