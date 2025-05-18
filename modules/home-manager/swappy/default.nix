{ config, lib, ... }:

let
  cfg = config.moduleopts.swappy;
in
{
  options.moduleopts.swappy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "swappy";
    };
  };
  config = lib.mkIf cfg.enable {
    xdg.configFile."swappy/config".text = ''
      [Default]
      save_dir = ${config.home.homeDirectory}/Pictures/Screenshots/
    '';
  };
}
