{
  config,
  lib,
  system,
  ...
}:

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
  config = lib.mkIf (cfg.enable && lib.hasSuffix "linux" system) {
    services.easyeffects = {
      enable = true;
    };
  };
}
