{ config, ... }:

{
  wayland.windowManager.sway.swaynag = {
    enable = true;

    settings = {
      "theme" = {
        background = "${config.colors.backgroundColor}00";
        border = "${config.colors.backgroundColor}00";
        border-bottom = "${config.colors.textColor}00";
        button-background = config.colors.activeColor;
        text = config.colors.textColor;
        button-text = config.colors.textColor;
        border-bottom-size = "0";
        message-padding = "5";
        details-background = "${config.colors.backgroundColor}00";
        details-border-size = "0";
        button-border-size = "3";
        button-gap = "5";
        button-dismiss-gap = "10";
        button-margin-right = "10";
        button-padding = "5";
        font = config.stylix.fonts.sansSerif.name + " " + (toString config.stylix.fonts.sizes.applications);
      };
    };
  };
}
