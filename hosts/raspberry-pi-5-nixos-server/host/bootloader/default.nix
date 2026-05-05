{ inputs, ... }:

{
  boot = {
    kernelPackages = inputs.nixos-raspberrypi.packages.aarch64-linux.linuxPackages_rpi5;
    kernelParams = [
      "rw"
      "loglevel=3"
      "8250.nr_uarts=11"
      "console=ttyAMA10,9600"
      "console=tty0"
    ];
    loader = {
      grub.enable = false;
      raspberry-pi = {
        enable = true;
        variant = "5";
        bootloader = "kernel";
      };
    };
    supportedFilesystems = [
      "ext4"
      "vfat"
    ];
    tmp.cleanOnBoot = true;
  };
}
