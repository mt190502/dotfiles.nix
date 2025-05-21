{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager.easyeffects;
in
{
  options.moduleopts.home-manager.easyeffects = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "easyeffects";
    };
  };
  config = lib.mkIf cfg.enable {
    services.easyeffects = {
      enable = true;
    };
  };
}
