{ config, lib, ... }:

let
  cfg = config.moduleopts.nixos.fontconfig;
in
{
  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      storageDriver = "btrfs";
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
