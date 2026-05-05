{ lib, ... }:

let
  kdeconnect = {
    from = 1714;
    to = 1764;
  };
  syncthing = [
    21027
    22000
  ];
in
{
  networking = {
    hostName = "thinkpad-190502";
    firewall = {
      enable = true;
      allowedTCPPorts = syncthing;
      allowedUDPPorts = syncthing;
      allowedTCPPortRanges = [ kdeconnect ];
      allowedUDPPortRanges = [ kdeconnect ];
    };
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };
}
