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
      kernelModules = [
        "kvm-amd"
        "v4l2loopback"
      ];
    };
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
      "amdgpu.dcdebugmask=0x610"
      "amdgpu.ppfeaturemask=0xfffd3fff"
    ];
  };
}
