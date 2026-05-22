{ pkgs, ... }:

rec {
  boot = {
    extraModprobeConfig = ''
      # KVM Configuration
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1

      # v4l2loopback Configuration
      options v4l2loopback devices=2
      options v4l2loopback video_nr=0,1
      options v4l2loopback card_label="Dummy Output,OBS Virtual Camera"
      options v4l2loopback exclusive_caps=1
    '';
    extraModulePackages = with boot.kernelPackages; [
      v4l2loopback
    ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
      ];
      kernelModules = [
        "dm-snapshot"
        "cryptd"
        "kvm-intel"
        "v4l2loopback"
      ];
      services.udev.rules = ''
        SUBSYSTEM=="pci", KERNEL=="0000:00:14.0", RUN+="/bin/sh -c 'echo disabled > /sys/bus/pci/devices/0000:00:14.0/power/wakeup'"
      '';
    };
    kernelPackages = pkgs.linuxPackages_6_18;
    kernelParams = [
      "rw"
      "loglevel=3"
      "intel_iommu=on"
      "iommu=pt"
      "skew_tick=1"
      "net.ifnames=0"
    ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    supportedFilesystems = [
      "ext4"
      "vfat"
    ];
    tmp.cleanOnBoot = true;
  };
}
