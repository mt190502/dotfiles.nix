{ config, ... }:

{
  boot = {
    extraModprobeConfig = ''
      # KVM Configuration
      options kvm_amd nested=1
      options kvm_amd emulate_invalid_guest_state=0
      options kvm ignore_msrs=1

      # Iwlwifi Configuration
      options iwlwifi power_save=0
      options iwlwifi bt_coex_active=0

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
        "xhci_pci"
        "ahci"
        "nvme"
      ];
      kernelModules = [ "kvm-amd" ];
      services.udev.rules = ''
        SUBSYSTEM=="pci", KERNEL=="0000:04:00.3", RUN+="/bin/sh -c 'echo disabled > /sys/bus/pci/devices/0000:04:00.3/power/wakeup'"
        SUBSYSTEM=="pci", KERNEL=="0000:04:00.4", RUN+="/bin/sh -c 'echo disabled > /sys/bus/pci/devices/0000:04:00.4/power/wakeup'"
      '';
    };
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
      "acpi.ec_no_wakeup=1"
      #"gpiolib_acpi.ignore_wake=AMDI0030:00@7"
      #"pcie_port_pm=off"
    ];
  };
}
