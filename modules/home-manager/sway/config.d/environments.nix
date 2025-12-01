{ config, lib, pkgs, ... }:

{
  wayland.windowManager.sway = {
    extraConfigEarly = ''
      #~~~ sway
      set $altMod        Mod1

      #~~~ apps
      set $browser       ${lib.getExe pkgs.flatpak} run io.gitlab.librewolf-community
      set $filemanager   ${lib.getExe config.wrapped.dolphin}
      set $mediaplayer   ${lib.getExe pkgs.mpv}
    '';
  };
}
