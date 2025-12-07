{
  config,
  lib,
  system,
  ...
}:

let
  cfg = config.moduleopts.home-manager.kdeconnect;
in
{
  options.moduleopts.home-manager.kdeconnect = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "kdeconnect";
    };
  };
  config = lib.mkIf (cfg.enable && lib.hasSuffix "linux" system) {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
