{
  config,
  lib,
  pkgs,
  ...
}:

{
  wayland.windowManager.sway = {
    extraConfigEarly = ''
      #~~~ sway
      set $altMod        Mod1

      #~~~ apps
      set $browser       ${lib.getExe pkgs.flatpak} run io.gitlab.librewolf-community
      set $filemanager   ${
        lib.getExe config.wrapped.${config.moduleopts.home-manager.preferred.file-manager}
      }
      set $mediaplayer   ${lib.getExe config.wrapped.mpv}
    '';
  };
}
