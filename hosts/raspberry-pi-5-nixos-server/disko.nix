{
  disko.devices = {
    disk = {
      SDCARD = {
        type = "disk";
        device = "/dev/mmcblk0";
        content = {
          type = "gpt";
          partitions = {
            BOOT = {
              priority = 1;
              name = "bootfs";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = [
                  "-F32"
                  "-n"
                  "bootfs"
                ];
                mountpoint = "/boot/firmware";
                mountOptions = [
                  "noatime"
                  "noauto"
                  "x-systemd.automount"
                  "x-systemd.idle-timeout=1min"
                ];
              };
            };
            ROOT = {
              device = "/dev/mmcblk0p2";
              priority = 2;
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = [
                  "-L"
                  "rootfs"
                ];
                mountpoint = "/";
                mountOptions = [
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
  };
}
