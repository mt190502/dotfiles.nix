{ config, ... }:

with config.lib.stylix.colors.withHashtag;
let
  activeColor = base02;
  inactiveColor = base0F;
  inactiveColor2 = base0D;
  urgentColor = "#FF0000";

  fonts.size = config.stylix.fonts.sizes.applications + 0.0;

in
{
  wayland.windowManager.sway.config = {
    inherit fonts;
    colors = {
      background = activeColor;

      focused = {
        background = activeColor;
        border = activeColor;
        text = base06;
        indicator = activeColor;
        childBorder = activeColor;
      };

      focusedInactive = {
        background = inactiveColor2;
        border = inactiveColor2;
        text = base06;
        indicator = inactiveColor2;
        childBorder = inactiveColor2;
      };

      unfocused = {
        background = inactiveColor;
        border = inactiveColor;
        text = base06;
        indicator = inactiveColor;
        childBorder = inactiveColor;
      };

      urgent = {
        background = urgentColor;
        border = urgentColor;
        text = "#FFFFFF";
        indicator = urgentColor;
        childBorder = urgentColor;
      };
    };
  };
}
