{
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--accept-dns"
      "--accept-routes"
      "--ssh"
    ];
  };
}
