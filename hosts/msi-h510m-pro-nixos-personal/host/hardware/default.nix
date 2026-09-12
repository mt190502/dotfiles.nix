{ lib, pkgs, ... }:

rec {
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    cpu.intel.updateMicrocode = lib.mkDefault hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ intel-media-driver ];
    };
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };
  powerManagement = {
    cpuFreqGovernor = "performance";
  };
}
