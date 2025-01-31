{
  config,
  lib,
  ...
}:

{
  options.pkgconfig.swaylock = {
    enable = lib.mkEnableOption "Enable swaylock configuration.";
  };

  config.programs.swaylock = {
    enable = config.pkgconfig.swaylock.enable;
    package = config.wrappedPkgs.swaylock;

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

      bs-hl-color = config.colors.activeColor;
      caps-lock-bs-hl-color = config.colors.activeColor;
      caps-lock-key-hl-color = config.colors.activeColor;
      key-hl-color = config.colors.activeColor;

      layout-bg-color = config.colors.backgroundColor;
      layout-border-color = config.colors.activeColor;
      #layout-text-color = "#FFFFFF";

      separator-color = config.colors.backgroundColor;

      inside-color = "${config.colors.backgroundColor}00";
      line-color = config.colors.backgroundColor;
      ring-color = config.colors.inactiveColor;
      text-color = "#FFFFFF";

      inside-clear-color = "${config.colors.backgroundColor}00";
      line-clear-color = config.colors.backgroundColor;
      ring-clear-color = config.colors.inactiveColor;
      text-clear-color = "#FFFFFF";

      inside-caps-lock-color = "${config.colors.backgroundColor}00";
      line-caps-lock-color = config.colors.backgroundColor;
      ring-caps-lock-color = config.colors.inactiveColor;
      text-caps-lock-color = "#FFFFFF";

      inside-ver-color = "${config.colors.backgroundColor}00";
      line-ver-color = config.colors.backgroundColor;
      ring-ver-color = config.colors.inactiveColor;
      text-ver-color = "#FFFFFF";

      inside-wrong-color = "${config.colors.backgroundColor}00";
      line-wrong-color = config.colors.backgroundColor;
      ring-wrong-color = config.colors.urgentColor;
      text-wrong-color = config.colors.urgentColor;

      #~~~ keyboard layout config
      #show-keyboard-layout = true;
      hide-keyboard-layout = true;
    };
  };
}
