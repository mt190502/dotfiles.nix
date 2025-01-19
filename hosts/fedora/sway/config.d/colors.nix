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
    colors = {
      background = config.colors.activeColor;

      focused = {
        background = config.colors.activeColor;
        border = config.colors.activeColor;
        text = config.colors.textColor;
        indicator = config.colors.activeColor;
        childBorder = config.colors.activeColor;
      };

      focusedInactive = {
        background = config.colors.inactiveColor2;
        border = config.colors.inactiveColor2;
        text = config.colors.textColor;
        indicator = config.colors.inactiveColor2;
        childBorder = config.colors.inactiveColor2;
      };

      unfocused = {
        background = config.colors.inactiveColor;
        border = config.colors.inactiveColor;
        text = config.colors.textColor;
        indicator = config.colors.inactiveColor;
        childBorder = config.colors.inactiveColor;
      };

      urgent = {
        background = config.colors.urgentColor;
        border = config.colors.urgentColor;
        text = "#FFFFFF";
        indicator = config.colors.urgentColor;
        childBorder = config.colors.urgentColor;
      };
    };
  };
}
