{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
in
{
  wayland.windowManager.hyprland.settings.env = [
    "$browser,${lib.getExe pkgs.flatpak} run io.gitlab.librewolf-community"
    "$filemanager,${lib.getExe config.wrapped.${cfg.preferred.file-manager}}"
    "$mediaplayer,${lib.getExe config.wrapped.mpv}"
  ];
}
