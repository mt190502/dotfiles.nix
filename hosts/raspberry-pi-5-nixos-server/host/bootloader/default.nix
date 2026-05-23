{ lib, inputs, ... }:

{
  boot = {
    kernelPackages = lib.mkForce inputs.nixos-raspberrypi.packages.aarch64-linux.linuxPackages_rpi5;
    kernelParams = [
      "cgroup_enable=memory"
      "8250.nr_uarts=11"
      "console=ttyAMA10,9600"
      "console=tty0"
    ];
    loader = {
      raspberry-pi = {
        enable = true;
        variant = "5";
        bootloader = "kernel";
      };
    };
  };
}
