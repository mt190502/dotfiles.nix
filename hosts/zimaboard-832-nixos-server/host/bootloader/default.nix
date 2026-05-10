{ pkgs, ... }:

rec {
  boot = {
    extraModprobeConfig = ''
      # KVM Configuration
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
    '';
    extraModulePackages = with boot.kernelPackages; [ ];
    initrd = {
      availableKernelModules = [
        "ahci"
        "igc"
        "r8169"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [
        "cryptd"
        "dm-snapshot"
        "kvm-intel"
      ];
      luks.devices.cryptroot.preOpenCommands = ''
        export PATH=$PATH:${pkgs.curl}/bin:${pkgs.gnused}/bin:${pkgs.util-linux}/bin
        ${pkgs.clevis}/bin/clevis luks unlock -d $(blkid -t PARTLABEL="disk-SSD-ROOT" -o device) -n cryptroot
      '';
      network = {
        enable = true;
        udhcpc.enable = true;
      };
    };
    kernelPackages = pkgs.linuxPackages_6_18;
    kernelParams = [
      "rw"
      "loglevel=3"
      "intel_iommu=on"
      "iommu=pt"
      "skew_tick=1"
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
