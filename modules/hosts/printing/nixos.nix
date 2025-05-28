{ config, lib, pkgs, ... }:

let
  cfg = config.moduleopts.nixos.printing;
in
{
  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [ canon-cups-ufr2 ];
      browsed.enable = true;
    };
  };
}
