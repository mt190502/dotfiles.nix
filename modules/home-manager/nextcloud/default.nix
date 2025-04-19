{
  config,
  lib,
  ...
}:

let
  cfg = config.moduleopts.nextcloud-client;
in
{
  options.moduleopts.nextcloud-client = {
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
