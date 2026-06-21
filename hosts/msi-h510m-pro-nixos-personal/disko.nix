{
  disko.devices = {
    disk = {
      NVME = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "EFI System Partition";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            HOME = {
              device = "/dev/nvme0n1p2";
              size = "800G";
              content = {
                type = "luks";
                name = "crypthome";
                enrollFido2 = true;
                enrollRecovery = false;
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/home";
                };
              };
            };
            ROOT = {
              device = "/dev/nvme0n1p3";
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                enrollFido2 = true;
                enrollRecovery = false;
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
