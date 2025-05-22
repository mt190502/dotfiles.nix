{ ... }:

{
  networking = {
    hostName = "190502";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22000
      ];
      allowedUDPPorts = [
        21027
        22000
      ];
    };
  };
}
