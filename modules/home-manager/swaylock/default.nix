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

      settings = with config.lib.stylix.colors; {
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

        bs-hl-color = base0B-hex;
        caps-lock-bs-hl-color = base0B-hex;
        caps-lock-key-hl-color = base0B-hex;
        key-hl-color = base0B-hex;

        layout-bg-color = base00-hex;
        layout-border-color = base01-hex;
        #layout-text-color = base05-hex;

        separator-color = base00-hex;

        inside-color = base00-hex;
        line-color = base00-hex;
        ring-color = base01-hex;
        text-color = base05-hex;

        inside-clear-color = base00-hex;
        line-clear-color = base00-hex;
        ring-clear-color = base08-hex;
        text-clear-color = base05-hex;

        inside-caps-lock-color = base00-hex;
        line-caps-lock-color = base00-hex;
        ring-caps-lock-color = base01-hex;
        text-caps-lock-color = base05-hex;

        inside-ver-color = base00-hex;
        line-ver-color = base00-hex;
        ring-ver-color = base0B-hex;
        text-ver-color = base05-hex;

        inside-wrong-color = base00-hex;
        line-wrong-color = base00-hex;
        ring-wrong-color = base08-hex;
        text-wrong-color = base05-hex;

        #~~~ keyboard layout config
        #show-keyboard-layout = true;
        hide-keyboard-layout = true;
      };
    };
  };
}
