{ config, lib, ... }:

{
  gtk = {
    enable = true;
    cursorTheme = {
      inherit (config.cursorcfg) name size;
      package = lib.mkForce config.cursorcfg.package;
    };
    font = {
      inherit (config.fontcfg.sansSerif) name;
      package = lib.mkForce config.fontcfg.sansSerif.package;
    };
    iconTheme = {
      name = config.iconthemecfg.dark;
      package = lib.mkForce config.iconthemecfg.package;
    };
    gtk4 = {
      inherit (config.gtk) theme;
      extraConfig = {
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
        gtk-enable-event-sounds = 0;
        gtk-enable-input-feedback-sounds = 0;
      };
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
