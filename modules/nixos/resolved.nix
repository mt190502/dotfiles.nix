{
  services.resolved = {
    enable = true;
    dnsovertls = "true";
    extraConfig = ''
      DNS=1.1.1.1 9.9.9.9
      DNSStubListener=no
    '';
  };
}
