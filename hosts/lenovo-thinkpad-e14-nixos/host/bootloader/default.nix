{
  config,
  pkgs,
  ...
}:

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
        "usbhid"
      ];
      kernelModules = [
        "dm-snapshot"
        "cryptd"
        "kvm-amd"
        "v4l2loopback"
      ];
      luks.devices = {
        "cryptroot".device = "/dev/disk/by-uuid/35d05b4f-3ffa-46c9-a8b9-ad578e80449a";
        "crypthome".device = "/dev/disk/by-uuid/e07c5ce6-810c-43a2-a97d-c0eb4994f7dc";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "rw"
      "loglevel=3"
      "amd_iommu=on"
      "iommu=pt"
      "skew_tick=1"
      "amdgpu.dcdebugmask=0x610"
      "amdgpu.ppfeaturemask=0xfffd3fff"
    ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    supportedFilesystems = [
      "btrfs"
      "ext4"
      "vfat"
    ];
    tmp.cleanOnBoot = true;
  };
}
