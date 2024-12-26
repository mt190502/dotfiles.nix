{ ... }:

let
  activeColor = "#5b9fcb";
  inactiveColor = "#3e6d8c";
  urgentColor = "#FF0000";
  color00 = "#12100c";
  color01 = "#689ACF";
  color02 = "#5177A7";
  color03 = "#90AED4";
  color04 = "#0A73C7";
  color05 = "#B3B6B8";
  color06 = "#318CCB";
  color07 = "#c8d4e3";
  color08 = "#302a1f";
  color09 = "#72c7ff";
  color10 = "#5998e9";
  color11 = "#a4dfff";
  color12 = "#0196ff";
  color13 = "#d1f1ff";
  color14 = "#2fb8ff";
  color15 = "#eefdff";
in {
  wayland.windowManager.sway.config = {
    colors = {
      background = activeColor;

      focused = {
        background = activeColor;
        border = activeColor;
        text = color15;
        indicator = activeColor;
        childBorder = activeColor;
      };

      unfocused = {
        background = inactiveColor;
        border = inactiveColor;
        text = color15;
        indicator = inactiveColor;
        childBorder = inactiveColor;
      };

      urgent = {
        background = urgentColor;
        border = urgentColor;
        text = color15;
        indicator = urgentColor;
        childBorder = urgentColor;
      };
    };
  };
}
