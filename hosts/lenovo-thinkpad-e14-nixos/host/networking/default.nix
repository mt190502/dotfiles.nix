let
  kdeconnect = {
    from = 1714;
    to = 1764;
  };
in
{
  networking = {
    hostName = "thinkpad-190502";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22000
      ];
      allowedTCPPortRanges = [
        kdeconnect
      ];
      allowedUDPPorts = [
        21027
        22000
      ];
      allowedUDPPortRanges = [
        kdeconnect
      ];
    };
    networkmanager.enable = true;
  };
}
