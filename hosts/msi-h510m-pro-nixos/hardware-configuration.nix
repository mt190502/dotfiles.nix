{
  config,
  lib,
  modulesPath,
  ...
}:

let
  btrfsopts = [
    "rw"
    "noatime"
    "compress=zstd:1"
    "ssd"
    "space_cache=v2"
  ];
  zfsopts = [
    "rw"
    "nodev"
    "xattr"
    "posixacl"
    "casesensitive"
  ];
  rootpool = {
    device = "rootpool/nixos-2025-10-27";
    fsType = "zfs";
    options = zfsopts;
  };
  homepool = {
    device = "homepool/nixos-2025-10-27";
    fsType = "zfs";
    options = zfsopts;
  };
  mkZfsHomeSubfolderMount = s: {
    device = "homepool/shared/${s}";
    fsType = "zfs";
    options = zfsopts;
  };
  mkNFSMount = dev: {
    device = dev;
    fsType = "nfs";
    options = [
      "rw"
      "relatime"
    ];
  };
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems = {
    #~ System mounts
    "/" = rootpool;

    #~ User mounts
    "/home" = homepool;
    "/home/taha/Android" = mkZfsHomeSubfolderMount "Android";
    "/home/taha/Desktop" = mkZfsHomeSubfolderMount "Desktop";
    "/home/taha/Documents" = mkZfsHomeSubfolderMount "Documents";
    "/home/taha/Downloads" = mkZfsHomeSubfolderMount "Downloads";
    "/home/taha/Music" = mkZfsHomeSubfolderMount "Music";
    "/home/taha/Pictures" = mkZfsHomeSubfolderMount "Pictures";
    "/home/taha/Public" = mkZfsHomeSubfolderMount "Public";
    "/home/taha/Templates" = mkZfsHomeSubfolderMount "Templates";
    "/home/taha/Videos" = mkZfsHomeSubfolderMount "Videos";

    #~ NFS mounts
    "/home/taha/Projects" = mkNFSMount "192.168.1.200:/mnt/ssd/data/projects";
    "/mnt/nfs/iso" = mkNFSMount "192.168.1.200:/mnt/ssd/iso";
    "/mnt/nfs/backup" = mkNFSMount "192.168.1.200:/mnt/ssd/backup";
    "/mnt/nfs/depo2" = mkNFSMount "192.168.1.200:/mnt/ssd/data/depo2";

    #~ Other mounts
    "/mnt/ssd" = {
      device = "/dev/disk/by-uuid/6ef5c4c9-6566-4814-81b7-c9b0f6c582ca";
      fsType = "btrfs";
      options = btrfsopts;
    };
    "/mnt/hdd" = {
      device = "/dev/disk/by-uuid/45bd2cb5-83af-4270-88ec-86be45037b7a";
      fsType = "ext4";
      options = [
        "rw"
        "relatime"
      ];
    };
    "/boot/efi" = {
      device = "/dev/disk/by-uuid/6C94-2412";
      fsType = "vfat";
      options = [
        "rw"
        "relatime"
        "fmask=0077"
        "dmask=0077"
        "codepage=437"
        "iocharset=ascii"
        "shortname=mixed"
        "errors=remount-ro"
      ];
    };
  };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
