{
  config,
  lib,
  ...
}:

let
  cfg = config.moduleopts.cliphist;
in
{
  options.moduleopts.cliphist = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "cliphist";
    };
  };
  config = lib.mkIf cfg.enable {
    services.cliphist = {
      enable = true;
      allowImages = true;
      systemdTargets = [
        "sway-session.target"
      ];
    };
  };
}