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
    "/home" = {
      device = "/dev/disk/by-uuid/a436a5aa-fce4-4d45-a324-48c68882d8b3";
      fsType = "ext4";
    };

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
