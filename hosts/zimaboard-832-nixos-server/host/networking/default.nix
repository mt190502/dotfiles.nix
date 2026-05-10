{ lib, ... }:

let
  syncthing = [
    21027
    22000
  ];
in
{
  networking = {
    hostName = "zimaboard-190502";
    firewall = {
      enable = true;
      allowedTCPPorts = syncthing;
      allowedUDPPorts = syncthing;
      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [ ];
    };
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };
}
