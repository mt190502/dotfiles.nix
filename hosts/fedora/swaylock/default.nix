{ config, lib, ... }:

{
  options.pkgconfig.swaylock = {
    enable = lib.mkEnableOption {
      type = lib.types.bool;
      default = true;
      description = "Enable swaylock configuration.";
    };
  };

  config.programs.swaylock = {
    enable = config.pkgconfig.swaylock.enable;

    settings = {
      #################################################
      ##
      #### SwayLock
      ##
      #################################################
      #~~~ #~~~ caps lock text ~~~# ~~~#
      #disable-caps-lock-text = true;
      indicator-caps-lock = true;

      #~~~ #~~~ fonts ~~~# ~~~#
      font = "Ubuntu Medium";
      font-size = 20;

      #~~~ #~~~ indicator ~~~# ~~~#
      #~~~ settings
      #indicator-idle-visible;           #~~~ always show indicator
      indicator-radius = 100;
      indicator-thickness = 20;
      #line-uses-inside = true;
      #line-uses-ring = true;
      #no-unlock-indicator = true;       #~~~ hide indicator

      bs-hl-color = "#5b9fcb";
      caps-lock-bs-hl-color = "#5b9fcb";
      caps-lock-key-hl-color = "#5b9fcb";
      key-hl-color = "#5b9fcb";

      layout-bg-color = "#12100c";
      layout-border-color = "#5b9fcb";
      #layout-text-color = "#eefdff";

      separator-color = "#12100c";

      inside-color = "#12100c00";
      line-color = "#12100c";
      ring-color = "#302a1f";
      text-color = "#eefdff";

      inside-clear-color = "#12100c00";
      line-clear-color = "#12100c";
      ring-clear-color = "#302a1f";
      text-clear-color = "#eefdff";

      inside-caps-lock-color = "#12100c00";
      line-caps-lock-color = "#12100c";
      ring-caps-lock-color = "#302a1f";
      text-caps-lock-color = "#eefdff";

      inside-ver-color = "#12100c00";
      line-ver-color = "#12100c";
      ring-ver-color = "#302a1f";
      text-ver-color = "#eefdff";

      inside-wrong-color = "#12100c00";
      line-wrong-color = "#12100c";
      ring-wrong-color = "#FF0000";
      text-wrong-color = "#FF0000";

      #~~~ keyboard layout config
      #show-keyboard-layout = true;
      hide-keyboard-layout = true;
    };
  };
}
