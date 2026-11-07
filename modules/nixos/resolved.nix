{
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "1.1.1.1"
        "9.9.9.9"
      ];
      DNSOverTLS = "opportunistic";
    };
  };
}
