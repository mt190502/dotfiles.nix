{
  config,
  osConfig,
  lib,
  ...
}:

let
  cfg = config.moduleopts.home-manager.kdeconnect;
  nixcfg = osConfig.moduleopts.nixos.kdeconnect;
in
{
  options.moduleopts.home-manager.kdeconnect = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "kdeconnect";
    };
  };
  config = lib.mkIf cfg.enable {
    services.kdeconnect = {
      enable = !nixcfg.enable;
      package = lib.mkIf (!nixcfg.enable) config.wrapped.kdeconnect;
      indicator = true;
    };
  };
}
