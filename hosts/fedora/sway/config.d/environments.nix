{ config, ... }:

{
  wayland.windowManager.sway = {
    extraConfigEarly = ''
      #~~~ sway
      set $altMod        Mod1

      #~~~ apps
      set $browser       flatpak run io.gitlab.librewolf-community
      set $filemanager   ${config.wrappedPkgs.dolphin}/bin/dolphin
      set $mediaplayer   ${config.programs.mpv.package}/bin/mpv
    '';
  };
}
