{
  config,
  lib,
  pkgs,
  ...
}:

with config.stylix.customColors.withHashtag;
{
  config = lib.mkIf (lib.hasSuffix "linux" pkgs.stdenv.hostPlatform.system) {
    programs.mtshell.osd = {
      enable = true;
      bg = background;
      inherit text border;
      accent = active;
      fontName = config.stylix.fonts.sansSerif.name;
      volumeIcons = [
        " "
        " "
        " "
        " "
        " "
      ];
      volumeMutedIcon = "󰝟";
      brightnessIcons = [
        "󰃞"
        "󰃝"
        "󰃟"
        "󰃠"
        "󰃚"
      ];
    };
  };
}
