{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.nixos.kdeconnect;
in
{
  config = lib.mkIf cfg.enable {
    programs.kdeconnect = {
      enable = true;
      package = pkgs.kdePackages.kdeconnect-kde;
    };
  };
}
