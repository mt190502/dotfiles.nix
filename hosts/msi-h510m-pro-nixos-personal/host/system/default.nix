{
  fileSystems = {
    "/home/rose/win" = {
      device = "192.168.1.200:/mnt/ssd/nfs/win";
      fsType = "nfs";
      options = [
        "nfsvers=4"
        "noauto"
        "nofail"
        "x-systemd.automount"
      ];
    };
    "/mnt/nfs" = {
      device = "192.168.1.200:/mnt/ssd/nfs";
      fsType = "nfs";
      options = [
        "nfsvers=4"
        "noauto"
        "nofail"
        "x-systemd.automount"
      ];
    };
  };
  xdg.autostart.enable = true;
}
