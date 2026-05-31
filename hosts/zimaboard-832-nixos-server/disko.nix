{
  disko.devices = {
    disk = {
      SSD = {
        type = "disk";
        device = "/dev/sda";
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
            ROOT = {
              device = "/dev/sda2";
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
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
      DATASSD = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            PART1 = {
              device = "/dev/sdb1";
              size = "512G";
              content = {
                type = "luks";
                name = "cryptpart1";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/ssd/data";
                };
              };
            };
            PART2 = {
              device = "/dev/sdb2";
              size = "100%";
              content = {
                type = "luks";
                name = "cryptpart2";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/ssd/nfs";
                };
              };
            };
          };
        };
      };
    };
  };
}
