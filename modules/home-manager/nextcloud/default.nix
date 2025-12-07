{
  config,
  lib,
  system,
  ...
}:

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
  config = lib.mkIf (cfg.enable && lib.hasSuffix "linux" system) {
    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };
}
