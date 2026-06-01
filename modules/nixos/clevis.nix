{
  boot.initrd = {
    clevisLuksAskpass = {
      enable = true;
      useTang = true;
    };
    systemd = {
      network = {
        enable = true;
        wait-online.extraArgs = [ "-4" ];
        networks."10-eth" = {
          matchConfig = {
            Name = "eth0";
          };
          networkConfig = {
            DHCP = "ipv4";
          };
        };
      };
      targets.cryptsetup = {
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
      };
      services.systemd-udevd = {
        after = [ "systemd-modules-load.service" ];
      };
    };
  };
}
