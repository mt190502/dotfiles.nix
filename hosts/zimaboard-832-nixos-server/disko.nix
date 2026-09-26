{
  disko.devices = {
    disk = {
      SSD = {
        type = "disk";
        device = "/dev/disk/by-id/ata-KIOXIA-EXCERIA_SATA_SSD_Y1OB70GUKFV4";
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
        device = "/dev/disk/by-id/ata-KIOXIA-EXCERIA_SATA_SSD_Y31B83C8K0Z5";
        content = {
          type = "gpt";
          partitions = {
            PART1 = {
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
