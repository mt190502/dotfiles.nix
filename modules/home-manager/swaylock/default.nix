{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  home = config.home.homeDirectory;
in
{
  options.moduleopts.home-manager.swaylock = {
    systemd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable systemd service for swaylock";
    };
  };
  config = lib.mkIf (cfg.preferred.lock-app == "swaylock") {
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock;
      settings = with config.stylix.customColors.withHex; {
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

        bs-hl-color = active;
        caps-lock-bs-hl-color = active;
        caps-lock-key-hl-color = active;
        key-hl-color = active;

        layout-bg-color = background;
        layout-border-color = inactive;
        #layout-text-color = text;

        separator-color = background;

        inside-color = background;
        line-color = background;
        ring-color = inactive;
        text-color = text;

        inside-clear-color = background;
        line-clear-color = background;
        ring-clear-color = urgent;
        text-clear-color = text;

        inside-caps-lock-color = background;
        line-caps-lock-color = background;
        ring-caps-lock-color = inactive;
        text-caps-lock-color = text;

        inside-ver-color = background;
        line-ver-color = background;
        ring-ver-color = active;
        text-ver-color = text;

        inside-wrong-color = background;
        line-wrong-color = background;
        ring-wrong-color = urgent;
        text-wrong-color = text;

        #~~~ keyboard layout config
        #show-keyboard-layout = true;
        hide-keyboard-layout = true;
      };
    };
    systemd.user.services = lib.mkIf cfg.swaylock.systemd.enable {
      session-lock = {
        Unit = {
          Description = "Session Lock";
          Before = [
            "suspend.target"
            "sleep.target"
            "hibernate.target"
          ];
          Wants = [
            "suspend.target"
            "sleep.target"
            "hibernate.target"
          ];
        };
        Service = {
          Type = "forking";
          ExecStart = "${home}/.local/bin/blurlock";
        };
        Install = {
          WantedBy = [
            "sleep.target"
            "suspend.target"
            "hibernate.target"
          ];
        };
      };
    };
  };
}
