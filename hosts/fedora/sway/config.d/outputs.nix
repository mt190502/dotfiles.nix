{ config, ... }:

{
  wayland.windowManager.sway.config = {
    output = {
      "HDMI-A-4" = {
        mode = "1920x1080";
        position = "0,0";
      };
      "DP-2" = {
        mode = "1920x1080";
        position = "1920,0";
      };
      "*" = {
        adaptive_sync = "on";
        bg = "${config.stylix.image} fill";
        subpixel = "rgb";
      };
    };
  };
}
