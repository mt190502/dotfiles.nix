{ lib, pkgs, ... }:

{
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      config = {
        common.default = "*";
        sway = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        };
      };
    };
    configFile."xdg-desktop-portal-wlr/config".text = ''
      [screencast]
      chooser_type=simple
      chooser_cmd=${lib.getExe pkgs.slurp} -f 'Monitor: %o' -or
    '';
  };
}
