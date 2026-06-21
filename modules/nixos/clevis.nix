{ inputs, ... }:

{
  boot.initrd = {
    clevisLuksAskpass = {
      enable = true;
      useTang = true;
    };
    network = {
      ssh = {
        enable = true;
        port = 2222;
        authorizedKeys = (import "${inputs.self}/users/keys.nix").all;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
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
