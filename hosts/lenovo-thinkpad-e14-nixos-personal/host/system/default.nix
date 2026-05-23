{ pkgs, ... }:

{
  fileSystems."/home/rose/win" = {
    device = "zimaboard-190502:/mnt/ssd/nfs/win";
    fsType = "nfs";
    options = [
      "nfsvers=4"
      "noauto"
      "nofail"
      "x-systemd.automount"
    ];
  };
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
