{ config, lib, ... }:

{
  options.mako = {
    enable = lib.mkEnableOption {
      type = lib.types.bool;
      default = true;
      description = "Enable mako configuration.";
    };
  };
  config.services.mako = {
    enable = config.mako.enable;

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
