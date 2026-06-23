{ lib, pkgs, ... }:

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
  services.udev = {
    extraHwdb = ''
      evdev:name:ThinkPad Extra Buttons:dmi:bvn*:bvr*:bd*:svnLENOVO*:pn*:*
       KEYBOARD_KEY_4c=previoussong                     # Answer Voip call key
       KEYBOARD_KEY_4d=nextsong                         # Hang Voip call key
       KEYBOARD_KEY_45=playpause                        # Favorites
    '';
    extraRules = with pkgs; ''
      ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
      ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:04:00.3", RUN+="/bin/sh -c 'echo disabled > /sys/bus/pci/devices/0000:04:00.3/power/wakeup'"
      ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:04:00.4", RUN+="/bin/sh -c 'echo disabled > /sys/bus/pci/devices/0000:04:00.4/power/wakeup'"
      ACTION=="add", SUBSYSTEM=="sound", KERNEL=="controlC1", RUN+="${writeShellScript "micmute-led-wrapper" ''
        exec ${lib.getExe' systemd "systemd-run"} --no-block --unit=micmute-led-setup ${writeShellScript "micmute-led-setup" ''
          ${lib.getExe' kmod "modprobe"} snd_ctl_led
          ${lib.getExe' alsa-utils "alsactl"} init 1 || true
          echo 'Mic ACP LED Capture Switch' | ${lib.getExe' coreutils-full "tee"} /sys/class/sound/ctl-led/mic/card1/attach 2>/dev/null || true
        ''}
      ''}"
    '';
  };
}
