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
    device = "/dev/disk/by-uuid/34af6101-fbe1-4bbc-93ff-6ac4600a229a";
    fsType = "btrfs";
    options = (if subvol != null then [ "subvol=/nixos-2025-06-15/${subvol}" ] else [ ]) ++ btrfsopts;
  };
  mkBtrfsHomeMount = subvol: {
    device = "/dev/disk/by-uuid/1c2a3dfb-8628-4a52-8bc0-c9d59ba3a825";
    fsType = "btrfs";
    options =
      (if subvol != null then [ "subvol=/folders/${subvol}" ] else [ "subvol=/users" ]) ++ btrfsopts;
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
    "/home/taha/Projects" = mkBtrfsHomeMount "Projects";
    "/home/taha/Public" = mkBtrfsHomeMount "Public";
    "/home/taha/Templates" = mkBtrfsHomeMount "Templates";
    "/home/taha/Videos" = mkBtrfsHomeMount "Videos";

    #~ Other mounts
    "/boot/efi" = {
      device = "/dev/disk/by-uuid/2CBB-908E";
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
