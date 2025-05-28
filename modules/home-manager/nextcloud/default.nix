{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager.nextcloud-client;
in
{
  options.moduleopts.home-manager.nextcloud-client = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "nextcloud";
    };
  };
  config = lib.mkIf cfg.enable {
    services.nextcloud-client = {
      enable = true;
      package = config.wrapped.nextcloud-client;
      startInBackground = true;
    };
  };
}
