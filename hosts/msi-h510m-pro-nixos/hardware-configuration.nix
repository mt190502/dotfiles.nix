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
  mkBtrfsSysMount = subvol: {
    device = "/dev/disk/by-uuid/11f051d8-af89-493d-920a-4539ed69ead6";
    fsType = "btrfs";
    options = (if subvol != null then [ "subvol=/nixos-2025-06-02/${subvol}" ] else [ ]) ++ btrfsopts;
  };
  mkBtrfsHomeMount = subvol: {
    device = "/dev/disk/by-uuid/48cff87f-003c-4358-a4f7-81705e1025d1";
    fsType = "btrfs";
    options =
      (if subvol != null then [ "subvol=/folders/${subvol}" ] else [ "subvol=/users" ]) ++ btrfsopts;
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
    "/" = mkBtrfsSysMount "@";
    "/opt" = mkBtrfsSysMount "@opt";
    "/root" = mkBtrfsSysMount "@root";
    "/srv" = mkBtrfsSysMount "@srv";
    "/usr/local" = mkBtrfsSysMount "@usr/local";
    "/var" = mkBtrfsSysMount "@var";
    "/var/btrfs" = mkBtrfsSysMount null;

    #~ User mounts
    "/home" = mkBtrfsHomeMount null;
    "/home/taha/Android" = mkBtrfsHomeMount "Android";
    "/home/taha/Desktop" = mkBtrfsHomeMount "Desktop";
    "/home/taha/Documents" = mkBtrfsHomeMount "Documents";
    "/home/taha/Downloads" = mkBtrfsHomeMount "Downloads";
    "/home/taha/Music" = mkBtrfsHomeMount "Music";
    "/home/taha/Pictures" = mkBtrfsHomeMount "Pictures";
    "/home/taha/Public" = mkBtrfsHomeMount "Public";
    "/home/taha/Templates" = mkBtrfsHomeMount "Templates";
    "/home/taha/Videos" = mkBtrfsHomeMount "Videos";

    #~ NFS mounts
    "/home/taha/Projects" = mkNFSMount "192.168.1.200:/mnt/ssd/data/projects";
    "/mnt/iso" = mkNFSMount "192.168.1.200:/mnt/ssd/iso";

    #~ Other mounts
    "/mnt/ssd" = {
      device = "/dev/disk/by-uuid/6ef5c4c9-6566-4814-81b7-c9b0f6c582ca";
      fsType = "btrfs";
      options = btrfsopts;
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
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
