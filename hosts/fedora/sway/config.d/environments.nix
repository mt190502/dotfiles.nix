{ ... }:

{
  wayland.windowManager.sway = {
    extraConfigEarly = ''
      #~~~ sway
      set $altMod        Mod1

      #~~~ apps
      set $browser       flatpak run io.gitlab.librewolf-community
      set $filemanager   dolphin
      set $mediaplayer   mpv
    '';
  };
}
