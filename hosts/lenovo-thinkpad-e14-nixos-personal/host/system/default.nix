{ lib, pkgs, ... }:

{
  services = {
    fprintd = {
      enable = true;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-elan;
      };
    };
    tlp.settings = {
      PCIE_ASPM_ON_BAT = "powersave";
      PLATFORM_PROFILE_ON_BAT = lib.mkForce "low-power";
      RUNTIME_PM_ON_BAT = "auto";
      SOUND_POWER_SAVE_ON_BAT = "1";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 85;
      USB_AUTOSUSPEND_ON_BAT = "auto";
      WOL_DISABLE = lib.mkForce "Y";
    };
  };
  systemd.services = {
    fprintd = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "simple";
    };
    systemd-suspend.serviceConfig.ExecStart = lib.mkForce [
      ""
      "${pkgs.writeShellScript "systemd-suspend-direct" ''
        start=$(date +%s)
        sync
        echo mem > /sys/power/state
        elapsed=$(( $(date +%s) - start ))
        if [ "$elapsed" -lt 8 ]; then
          sleep 1
          echo mem > /sys/power/state
        fi
      ''}"
    ];
  };
  xdg = {
    autostart.enable = true;
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      config.common.default = "*";
    };
  };
}
