{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.nixos.lanzaboote;
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];
  config = lib.mkIf cfg.enable {
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      settings = {
        default = "@saved";
      };
    };
    boot.loader.systemd-boot.enable = lib.mkForce false;
    environment.systemPackages = [
      pkgs.sbctl
    ];
  };
}
