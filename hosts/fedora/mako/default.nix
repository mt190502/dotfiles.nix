{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.pkgconfig.mako = {
    enable = lib.mkEnableOption "Enable mako configuration.";
  };
  config.services.mako = {
    enable = config.pkgconfig.mako.enable;
    package = pkgs.mako;

    backgroundColor = "#12100c";
    borderColor = "#5b9fcb";
    borderRadius = 0;
    borderSize = 5;
    defaultTimeout = 10000;
    font = "Ubuntu Medium 10";
    ignoreTimeout = true;
    layer = "overlay";
    margin = "16";
    maxIconSize = 64;
    sort = "-time";
    textColor = "#FFFFFF";

    extraConfig = ''
      [urgency=high]
      border-color=#FF0000
      default-timeout=0

      [mode=dnd]
      invisible=1
    '';
  };
}
