{
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
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
