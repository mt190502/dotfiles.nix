{
  boot = {
    extraModprobeConfig = ''
      # KVM Configuration
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
    '';
    initrd = {
      availableKernelModules = [
        "ahci"
        "igc"
        "r8169"
        "xhci_pci"
      ];
      kernelModules = [
        "kvm-intel"
      ];
      network = {
        enable = true;
        udhcpc.enable = true;
      };
    };
    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
    ];
  };
}
