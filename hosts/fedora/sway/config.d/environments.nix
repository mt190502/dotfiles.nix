{ ... }:

{
  wayland.windowManager.sway = {
    extraConfigEarly = ''
      #~~~ sway
      set $altMod        Mod1

      #~~~ apps
      #set $appstore      plasma-discover
      set $browser       flatpak run io.gitlab.librewolf-community
      #set $imageviewer   flatpak run org.kde.gwenview
      set $filemanager   dolphin
      set $mediaplayer   mpv
    '';
  };
}
