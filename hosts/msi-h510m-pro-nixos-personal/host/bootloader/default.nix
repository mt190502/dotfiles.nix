{ config, ... }:

{
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
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    initrd = {
      availableKernelModules = [
        "ahci"
        "e1000e"
        "nvme"
        "xhci_pci"
      ];
      kernelModules = [
        "kvm-intel"
        "v4l2loopback"
      ];
      services.udev.rules = ''
        SUBSYSTEM=="pci", KERNEL=="0000:00:14.0", RUN+="/bin/sh -c 'echo disabled > /sys/bus/pci/devices/0000:00:14.0/power/wakeup'"
      '';
    };
    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
    ];
  };
}
