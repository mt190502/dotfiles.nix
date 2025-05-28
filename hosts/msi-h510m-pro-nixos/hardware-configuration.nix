{ config, lib, modulesPath, ... }:

let
  btrfsopts = [
    "rw"
    "noatime"
    "compress=zstd:1"
    "ssd"
    "space_cache=v2"
  ];
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/11f051d8-af89-493d-920a-4539ed69ead6";
    fsType = "btrfs";
    options = [ "subvol=nixos-2025-05-18/@" ] ++ btrfsopts;
  };
  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/11f051d8-af89-493d-920a-4539ed69ead6";
    fsType = "btrfs";
    options = [ "subvol=nixos-2025-05-18/@var" ] ++ btrfsopts;
  };
  fileSystems."/opt" = {
    device = "/dev/disk/by-uuid/11f051d8-af89-493d-920a-4539ed69ead6";
    fsType = "btrfs";
    options = [ "subvol=nixos-2025-05-18/@opt" ] ++ btrfsopts;
  };
  fileSystems."/root" = {
    device = "/dev/disk/by-uuid/11f051d8-af89-493d-920a-4539ed69ead6";
    fsType = "btrfs";
    options = [ "subvol=nixos-2025-05-18/@root" ] ++ btrfsopts;
  };
  fileSystems."/srv" = {
    device = "/dev/disk/by-uuid/11f051d8-af89-493d-920a-4539ed69ead6";
    fsType = "btrfs";
    options = [ "subvol=nixos-2025-05-18/@srv" ] ++ btrfsopts;
  };
  fileSystems."/boot/efi" = {
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
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/48cff87f-003c-4358-a4f7-81705e1025d1";
    fsType = "btrfs";
    options = [ "subvol=users" ] ++ btrfsopts;
  };
  fileSystems."/var/btrfs" = {
    device = "/dev/disk/by-uuid/11f051d8-af89-493d-920a-4539ed69ead6";
    fsType = "btrfs";
    options = btrfsopts;
  };
  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/6ef5c4c9-6566-4814-81b7-c9b0f6c582ca";
    fsType = "btrfs";
    options = btrfsopts;
  };
  fileSystems."/home/taha/Projects" = {
    device = "192.168.1.200:/mnt/ssd/data/projects";
    fsType = "nfs";
    options = [
      "rw"
      "relatime"
    ];
  };
  fileSystems."/mnt/iso" = {
    device = "192.168.1.200:/mnt/ssd/iso";
    fsType = "nfs";
    options = [
      "rw"
      "relatime"
    ];
  };

  swapDevices = [ ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
