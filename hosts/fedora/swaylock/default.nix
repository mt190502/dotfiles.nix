{
  config,
  lib,
  pkgs,
  ...
}:

with config.lib.stylix.colors.withHashtag;
{
  options.pkgconfig.swaylock = {
    enable = lib.mkEnableOption "Enable swaylock configuration.";
  };

  config.programs.swaylock = {
    enable = config.pkgconfig.swaylock.enable;
    package = config.lib.nixGL.wrap pkgs.swaylock;

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
      # font = "Ubuntu Medium";
      font = config.stylix.fonts.sansSerif.name;
      font-size = 20;

      #~~~ #~~~ indicator ~~~# ~~~#
      #~~~ settings
      #indicator-idle-visible;           #~~~ always show indicator
      indicator-radius = 100;
      indicator-thickness = 20;
      #line-uses-inside = true;
      #line-uses-ring = true;
      #no-unlock-indicator = true;       #~~~ hide indicator

      bs-hl-color = base0E;
      caps-lock-bs-hl-color = base0E;
      caps-lock-key-hl-color = base0E;
      key-hl-color = base0E;

      layout-bg-color = base02;
      layout-border-color = base0E;
      #layout-text-color = "#FFFFFF";

      separator-color = base02;

      inside-color = "${base02}00";
      line-color = base02;
      ring-color = base03;
      text-color = "#FFFFFF";

      inside-clear-color = "${base02}00";
      line-clear-color = base02;
      ring-clear-color = base03;
      text-clear-color = "#FFFFFF";

      inside-caps-lock-color = "${base02}00";
      line-caps-lock-color = base02;
      ring-caps-lock-color = base03;
      text-caps-lock-color = "#FFFFFF";

      inside-ver-color = "${base02}00";
      line-ver-color = base02;
      ring-ver-color = base03;
      text-ver-color = "#FFFFFF";

      inside-wrong-color = "${base02}00";
      line-wrong-color = base02;
      ring-wrong-color = "#FF0000";
      text-wrong-color = "#FF0000";

      #~~~ keyboard layout config
      #show-keyboard-layout = true;
      hide-keyboard-layout = true;
    };
  };
}
