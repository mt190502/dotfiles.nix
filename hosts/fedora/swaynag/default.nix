{ config, lib, ... }:

{
  options.pkgconfig.swaynag = {
    enable = lib.mkEnableOption "Enable swaynag configuration.";
  };
  config.wayland.windowManager.sway.swaynag = {
    enable = config.pkgconfig.swaynag.enable;
    settings = {
      "wpgtheme" = {
        background = "#12100c00";
        border = "#12100c00";
        border-bottom = "#eefdff00";
        button-background = "#3e6d8c";
        text = "#eefdff";
        button-text = "#eefdff";
        border-bottom-size = "0";
        message-padding = "5";
        details-background = "#12100c00";
        details-border-size = "0";
        button-border-size = "3";
        button-gap = "5";
        button-dismiss-gap = "10";
        button-margin-right = "10";
        button-padding = "5";
        font = "Ubuntu Medium 10";
      };
    };
  };
}
