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
        "xhci_pci"
      ];
      kernelModules = [
        "kvm-intel"
        "r8169"
      ];
    };
    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
    ];
  };
}
