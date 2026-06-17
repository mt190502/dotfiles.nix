{ config, lib, ... }:

let
  xftCfg = {
    gtk-xft-antialias = 1;
    gtk-xft-hinting = 1;
    gtk-xft-hintstyle = "hintslight";
    gtk-xft-rgba = "rgb";
    gtk-enable-event-sounds = 0;
    gtk-enable-input-feedback-sounds = 0;
  };
  xftCfgStr = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (n: v: "${n}=${if builtins.isString v then "\"${v}\"" else toString v}") xftCfg
  );
in
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
    gtk4 =
      let
        theme = config.gtk.theme;
      in
      {
        theme = lib.mkIf (theme != null) {
          inherit (theme) name;
          package = lib.mkForce theme.package;
        };
        extraConfig = xftCfg;
      };
    gtk3.extraConfig = xftCfg;
    gtk2.extraConfig = xftCfgStr;
  };
}
