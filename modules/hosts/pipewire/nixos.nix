{ config, lib, ... }:

let
  cfg = config.moduleopts.nixos.pipewire;
in
{
  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
