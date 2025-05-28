{
  config,
  lib,
  osConfig,
  ...
}:

let
  cfg = config.moduleopts.home-manager.kdeconnect;
  nixcfg = if (osConfig == null) then { enable = false; } else osConfig.moduleopts.nixos.kdeconnect;
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
      package = config.wrapped.kdeconnect;
      indicator = true;
    };
  };
}
