{ lib, ... }:

let
  nfs = [
    2049
  ];
  syncthing = [
    8384
    21027
    22000
  ];
in
{
  networking = {
    hostName = "zimaboard-190502";
    firewall = {
      enable = true;
      allowedTCPPorts = nfs ++ syncthing;
      allowedUDPPorts = nfs ++ syncthing;
      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [ ];
    };
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };
}
