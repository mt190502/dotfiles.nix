{
  config,
  inputs,
  lib,
  ...
}:

let
  cfg = config.moduleopts.home-manager.vicinae;
in
{
  imports = [ inputs.vicinae.homeManagerModules.default ];
  options.moduleopts.home-manager.vicinae = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "vicinae";
    };
  };
  config = lib.mkIf cfg.enable {
    services.vicinae = {
      enable = true;
      autoStart = true;
    };
  };
}
