{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ ];
  fileSystems."/mnt/nfs" = {
    device = "zimaboard-190502.lan:/mnt/ssd/nfs";
    fsType = "nfs";
    options = [
      "nfsvers=4"
      "noauto"
      "nofail"
      "x-systemd.automount"
    ];
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
