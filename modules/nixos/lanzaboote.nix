{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];
  config = {
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      # settings = {
      #   default = "@saved";
      # };
    };
    boot.loader.systemd-boot.enable = lib.mkForce false;
    environment.systemPackages = [
      pkgs.sbctl
    ];
  };
}
