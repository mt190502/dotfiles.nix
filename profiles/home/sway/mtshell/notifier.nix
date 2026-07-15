{ config, lib, ... }:

with config.stylix.customColors.withHashtag;
{
  programs.mtshell.notifier = {
    enable = lib.mkIf (config.preferences.bar == "mtshell") true;
    base = {
      bg = background;
      inherit
        text
        active
        inactive
        subtext
        urgent
        border
        ;
      fontName = config.stylix.fonts.sansSerif.name;
      fontSize = config.stylix.fonts.sizes.applications + 3;
    };
    controlCenter = {
      width = 500;
      height = 500;
      marginTop = 5;
      marginBottom = 5;
      marginLeft = 0;
      marginRight = 5;
      positionX = "right";
      positionY = "center";
    };
    mpris = {
      iconPlay = "";
      iconPause = "";
      iconNext = "";
      iconPrevious = "";
      iconShuffle = "";
      iconShuffleActive = "";
      iconRepeat = "";
      iconRepeatActive = "";
      iconRepeatOne = "";
      imageDisplaySize = 100;
    };
    iconDnd = "";
    iconDndActive = "";
    popup = {
      width = 400;
      margin = 8;
      iconSize = 64;
      duration = 5;
      maxVisible = 5;
    };
  };
}
