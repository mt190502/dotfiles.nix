{ inputs, ... }:

{
  boot = {
    kernelPackages = inputs.nixos-raspberrypi.packages.aarch64-linux.linuxPackages_rpi5;
    kernelParams = [
      "rw"
      "loglevel=3"
      "cgroup_enable=memory"
      "8250.nr_uarts=11"
      "console=ttyAMA10,9600"
      "console=tty0"
    ];
    kernel.sysctl = {
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.src_valid_mark" = 1;
      "net.ipv4.ip_forward" = 1;
    };
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
