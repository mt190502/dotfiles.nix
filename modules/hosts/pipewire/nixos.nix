{ config, lib, ... }:

let
  cfg = config.moduleopts.nixos.zram;
in
{
  config = lib.mkIf cfg.enable {
    pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
