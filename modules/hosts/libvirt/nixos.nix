{ config, lib, ... }:

let
  cfg = config.moduleopts.nixos.fontconfig;
in
{
  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = true;
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
