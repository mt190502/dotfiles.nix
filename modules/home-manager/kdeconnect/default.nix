{
  config,
  lib,
  ...
}:

let
  cfg = config.moduleopts.kdeconnect;
in
{
  options.moduleopts.kdeconnect = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "kdeconnect";
    };
  };
  config = lib.mkIf cfg.enable {
    services = {
      kdeconnect = {
        enable = true;
        package = config.wrapped.kdeconnect;
        indicator = true;
      };
    };
  };
}
