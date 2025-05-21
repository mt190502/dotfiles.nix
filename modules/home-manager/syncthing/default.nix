{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager.syncthing;
in
{
  options.moduleopts.home-manager.syncthing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "syncthing";
    };
  };
  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      tray.enable = true;
    };
  };
}
