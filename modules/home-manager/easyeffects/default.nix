{ config, lib, ... }:

let
  cfg = config.moduleopts.easyeffects;
in
{
  options.moduleopts.easyeffects = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "EasyEffects";
    };
  };
  config = lib.mkIf cfg.enable {
    services.easyeffects = {
      enable = true;
    };
  };
}
