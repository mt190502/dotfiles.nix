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
      inherit background;
      focused = {
        background = active;
        border = active;
        text = background;
        indicator = active;
        childBorder = active;
      };
      focusedInactive = {
        inherit text;
        background = inactive;
        border = inactive;
        indicator = inactive;
        childBorder = inactive;
      };
      unfocused = {
        inherit background text;
        border = background;
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
