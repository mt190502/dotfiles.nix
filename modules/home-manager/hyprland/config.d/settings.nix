{
  config,
  ...
}:

{
  wayland.windowManager.hyprland.settings = {
    group = {
      groupbar = {
        enabled = true;
        font_family = config.stylix.fonts.sansSerif.name;
        font_size = config.stylix.fonts.sizes.applications;
      };
    };

    decoration = {
      rounding = 12;
      # rounding_power = 2.0;
      blur = {
        enabled = true;
        size = 10;
        noise = 0.02;
        passes = 2;
        contrast = 1.1;
        vibrancy = 0.1696;
        xray = true;
      };
      shadow = {
        enabled = false;
      };
    };

    general = {
      border_size = 0;
      gaps_in = 5;
      gaps_out = 0;
    };

    animations = {
      enabled = "yes, please :)";

      bezier = [
        "easeOutQuint,0.23,1,0.32,1"
        "easeInOutCubic,0.65,0.05,0.36,1"
        "linear,0,0,1,1"
        "almostLinear,0.5,0.5,0.75,1.0"
        "quick,0.15,0,0.1,1"
      ];
      animation = "global, 1, 3.5, quick";
    };
  };
}
