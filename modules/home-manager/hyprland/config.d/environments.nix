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
    "$mediaplayer,${lib.getExe pkgs.mpv}"
  ];
}
