{
  services.k3s.enable = true;
  networking.firewall.allowedTCPPorts = [
    80
    443
    6443
  ];
}
