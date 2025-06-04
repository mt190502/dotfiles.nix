{ config, ... }:

{
  wayland.windowManager.sway.config = {
    fonts = {
      names = [
        config.stylix.fonts.sansSerif.name
        "pango"
      ];
      size = config.stylix.fonts.sizes.applications + 0.0;
    };
    colors = with config.stylix.customColors.withHashtag; {
      background = background;
      focused = {
        background = active;
        border = active;
        text = background;
        indicator = active;
        childBorder = active;
      };
      focusedInactive = {
        background = inactive;
        border = inactive;
        text = text;
        indicator = inactive;
        childBorder = inactive;
      };
      unfocused = {
        background = background;
        border = background;
        text = text;
        indicator = background;
        childBorder = background;
      };
      urgent = {
        background = urgent;
        border = urgent;
        text = background;
        indicator = urgent;
        childBorder = urgent;
      };
    };
  };
}
