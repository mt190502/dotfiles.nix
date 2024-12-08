{ config, lib, ... }:

{
  options.swappy = {
    enable = lib.mkEnableOption {
      type = lib.types.bool;
      default = true;
      description = "Enable swappy configuration.";
    };
  };

  config.xdg.configFile = if config.swappy.enable then {
    "swappy/config".text = ''
      [Default]
      save_dir = $HOME/Pictures/Screenshots/grim
    '';
  } else
    { };
}
