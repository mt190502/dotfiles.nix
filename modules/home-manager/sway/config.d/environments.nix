{ config, ... }:

{
  wayland.windowManager.sway = {
    extraConfigEarly = ''
      #~~~ sway
      set $altMod        Mod1

      #~~~ apps
      set $browser       flatpak run io.gitlab.librewolf-community
      set $filemanager   ${config.wrapped.dolphin}/bin/dolphin
      set $mediaplayer   ${config.wrapped.mpv}/bin/mpv
    '';
  };
}
