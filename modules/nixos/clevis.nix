{
  boot.initrd = {
    clevisLuksAskpass = {
      enable = true;
      useTang = true;
    };
    systemd = {
      enable = true;
      network = {
        enable = true;
        networks."10-eth" = {
          matchConfig = {
            Type = "ether";
          };
          networkConfig = {
            DHCP = "yes";
          };
        };
      };
    };
  };
}
