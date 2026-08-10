{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
      daemon.settings = {
        dns = [
          "1.1.1.1"
          "9.9.9.9"
          "8.8.8.8"
        ];
        ipv6 = true;
      };
    };
  };
}
