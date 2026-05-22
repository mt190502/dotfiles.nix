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
    hostName = "190502";
    firewall = {
      enable = true;
      allowedTCPPorts = syncthing;
      allowedUDPPorts = syncthing;
      allowedTCPPortRanges = [ kdeconnect ];
      allowedUDPPortRanges = [ kdeconnect ];
    };
    interfaces.eth0.wakeOnLan.enable = true;
    networkmanager = {
      enable = true;
      ensureProfiles = {
        profiles = {
          eth0 = {
            connection = {
              id = "eth0";
              type = "ethernet";
              interface-name = "eth0";
              autoconnect = true;
            };
            ipv4 = {
              method = "auto";
            };
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "auto";
            };
            ethernet = {
              wake-on-lan = 64;
            };
          };
        };
      };
    };
    useDHCP = lib.mkDefault true;
  };
}
