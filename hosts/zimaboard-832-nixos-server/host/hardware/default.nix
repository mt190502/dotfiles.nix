{ lib, ... }:

rec {
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
  powerManagement = {
    cpuFreqGovernor = "performance";
  };
}
