{
  config,
  inputs,
  lib,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
in
{
  imports = [ inputs.vicinae.homeManagerModules.default ];
  config = lib.mkIf (cfg.preferred.menu == "vicinae") {
    services.vicinae = {
      enable = true;
      autoStart = true;
    };
  };
}
