{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.swaylock;
in
{
  options.moduleopts.swaylock = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "swaylock";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock;

      settings = {
        #################################################
        #### SwayLock
        #################################################
        #~~~ #~~~ caps lock text ~~~# ~~~#
        #disable-caps-lock-text = true;
        indicator-caps-lock = true;

        #~~~ #~~~ fonts ~~~# ~~~#
        font = config.stylix.fonts.sansSerif.name;
        font-size = config.stylix.fonts.sizes.applications + 10;

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
        #layout-text-color = config.colors.textColor;

        separator-color = config.colors.backgroundColor;

        inside-color = "${config.colors.backgroundColor}00";
        line-color = config.colors.backgroundColor;
        ring-color = config.colors.inactiveColor;
        text-color = config.colors.textColor;

        inside-clear-color = "${config.colors.backgroundColor}00";
        line-clear-color = config.colors.backgroundColor;
        ring-clear-color = config.colors.inactiveColor;
        text-clear-color = config.colors.textColor;

        inside-caps-lock-color = "${config.colors.backgroundColor}00";
        line-caps-lock-color = config.colors.backgroundColor;
        ring-caps-lock-color = config.colors.inactiveColor;
        text-caps-lock-color = config.colors.textColor;

        inside-ver-color = "${config.colors.backgroundColor}00";
        line-ver-color = config.colors.backgroundColor;
        ring-ver-color = config.colors.inactiveColor;
        text-ver-color = config.colors.textColor;

        inside-wrong-color = "${config.colors.backgroundColor}00";
        line-wrong-color = config.colors.backgroundColor;
        ring-wrong-color = config.colors.urgentColor;
        text-wrong-color = config.colors.urgentColor;

        #~~~ keyboard layout config
        #show-keyboard-layout = true;
        hide-keyboard-layout = true;
      };
    };
  };
}
