{ config, lib, ... }:

{
  gtk = {
    enable = true;
    cursorTheme = {
      inherit (config.stylix.cursor) name size;
      package = lib.mkForce config.stylix.cursor.package;
    };
    font = {
      inherit (config.stylix.fonts.sansSerif) name;
      package = lib.mkForce config.stylix.fonts.sansSerif.package;
    };
    iconTheme = {
      name = config.stylix.iconTheme.dark;
      package = lib.mkForce config.stylix.iconTheme.package;
    };
    gtk4.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
    };
    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
    };
    gtk2.extraConfig = ''
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintslight"
      gtk-xft-rgba="rgb"
      gtk-enable-event-sounds=0
      gtk-enable-input-feedback-sounds=0
    '';
  };
}
