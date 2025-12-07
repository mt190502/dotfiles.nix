{
  config,
  lib,
  system,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
in
{
  options.moduleopts.home-manager.cliphist = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "cliphist";
    };
  };
  config =
    lib.mkIf (cfg.cliphist.enable && cfg.preferred.menu != "vicinae" && lib.hasSuffix "linux" system)
      {
        services.cliphist = {
          enable = true;
          allowImages = true;
          systemdTargets = [
            "${cfg.preferred.wm}-session.target"
          ];
        };
      };
}
