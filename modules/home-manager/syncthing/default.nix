{ config, lib, ... }:

let
  cfg = config.moduleopts.syncthing;
in
{
  options.moduleopts.syncthing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Syncthing";
    };
  };
  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      tray.enable = true;
    };
  };
}
