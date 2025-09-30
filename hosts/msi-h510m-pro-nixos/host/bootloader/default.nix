{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot = {
    extraModprobeConfig = ''
      # KVM Configuration
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
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
      nct6687d
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
        "kvm-intel"
        "nct6683"
        "v4l2loopback"
      ];
      services.udev.rules = ''SUBSYSTEM=="pci", KERNEL=="0000:00:14.0", RUN+="/bin/sh -c 'echo disabled > /sys/bus/pci/devices/0000:00:14.0/power/wakeup'"'';
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "rw"
      "loglevel=3"
      "intel_iommu=on"
      "iommu=pt"
      "intel_pstate=passive"
      "skew_tick=1"
      "amdgpu.dcdebugmask=0x610"
      "amdgpu.ppfeaturemask=0xfffd3fff"
    ];
    loader = {
      systemd-boot = {
        enable = true;
        extraInstallCommands = ''
          ${lib.getExe pkgs.gnused} -i 's|default.*|default @saved|g' /boot/efi/loader/loader.conf
        '';
      };
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
