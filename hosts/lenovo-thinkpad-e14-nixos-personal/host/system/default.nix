{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ ];
  services = {
    fprintd = {
      enable = true;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-elan;
      };
    };
  };
  systemd.services = {
    fprintd = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "simple";
    };
  };
  xdg = {
    autostart.enable = true;
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      config.common.default = "*";
    };
  };
}
