{ ... }:

{
  programs.alacritty.settings = {
    colors = {
      primary = {
        background = "#000000";
        foreground = "#C7C7C7";
      };
      cursor = {
        text    = "#FFFEFF";
        cursor  = "#FFB472";
      };
      normal = {
        black    = "#616161";
        red      = "#FF8272";
        green    = "#B4FA72";
        yellow   = "#FEFDC2";
        blue     = "#A5D5FE";
        magenta  = "#FF8FFD";
        cyan     = "#D0D1FE";
        white    = "#F1F1F1";
      };
      bright = {
        black    = "#8E8E8E";
        red      = "#FFC4BD";
        green    = "#D6FCB9";
        yellow   = "#FEFDD5";
        blue     = "#C1E3FE";
        magenta  = "#FFB1FE";
        cyan     = "#E5E6FE";
        white    = "#FFFEFF";
      };
    };
  };
}
