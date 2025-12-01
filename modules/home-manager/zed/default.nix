{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager.zed;
in
{
  options.moduleopts.home-manager.zed = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Zed editor";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
    };
  };
}
