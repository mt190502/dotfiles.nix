{ config, ... }:

{
  wayland.windowManager.sway.swaynag = {
    enable = true;
    settings = with config.stylix.customColors.withHashtag; {
      "theme" = {
        background = "${background}00";
        border = "${background}";
        border-bottom = "${text}00";
        button-background = "${background}";
        text = "${background}";
        button-text = "${text}";
        border-bottom-size = "0";
        message-padding = "5";
        details-background = "${background}00";
        details-border-size = "0";
        button-border-size = "3";
        button-gap = "5";
        button-dismiss-gap = "10";
        button-margin-right = "10";
        button-padding = "5";
        font = "${config.stylix.fonts.sansSerif.name} ${builtins.toString config.stylix.fonts.sizes.applications}";
      };
    };
  };
}
