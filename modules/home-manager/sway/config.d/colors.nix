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
    colors = with config.lib.stylix.colors.withHashtag; {
      background = base00;
      focused = {
        background = base0D;
        border = base0D;
        text = base00;
        indicator = base0D;
        childBorder = base0D;
      };
      focusedInactive = {
        background = base01;
        border = base01;
        text = base05;
        indicator = base01;
        childBorder = base01;
      };
      unfocused = {
        background = base00;
        border = base00;
        text = base05;
        indicator = base00;
        childBorder = base00;
      };
      urgent = {
        background = base08;
        border = base08;
        text = base00;
        indicator = base08;
        childBorder = base08;
      };
    };
  };
}
