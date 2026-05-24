{ lib, ... }:

rec {
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    cpu.amd.updateMicrocode = lib.mkDefault hardware.enableRedistributableFirmware;
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
  services.udev.extraHwdb = ''
    evdev:name:ThinkPad Extra Buttons:dmi:bvn*:bvr*:bd*:svnLENOVO*:pn*:*
     KEYBOARD_KEY_4c=previoussong                     # Answer Voip call key
     KEYBOARD_KEY_4d=nextsong                         # Hang Voip call key
     KEYBOARD_KEY_45=playpause                        # Favorites
  '';
  boot.extraModprobeConfig = ''
    options snd-hda-intel model=auto
  '';
}
