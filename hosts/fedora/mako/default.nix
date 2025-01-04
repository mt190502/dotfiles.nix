{ config, lib, ... }:

let
  makoOpacity = lib.toHexString (((builtins.ceil (config.stylix.opacity.popups * 100)) * 255) / 100);
in
{
  options.pkgconfig.mako = {
    enable = lib.mkEnableOption "Enable mako configuration.";
  };
  config.services.mako = {
    enable = config.pkgconfig.mako.enable;

    backgroundColor = config.colors.backgroundColor + makoOpacity;
    borderColor = config.colors.activeColor;
    textColor = config.colors.textColor;
    progressColor = "over ${config.colors.activeColor}";
    borderRadius = 0;
    borderSize = 5;
    defaultTimeout = 10000;
    font = config.stylix.fonts.serif.name + " " + (toString config.stylix.fonts.sizes.applications);
    ignoreTimeout = true;
    layer = "overlay";
    margin = "16";
    maxIconSize = 64;
    sort = "-time";

    extraConfig = ''
      [urgency=high]
      border-color=#FF0000
      default-timeout=0

      [mode=dnd]
      invisible=1
    '';
  };
}
