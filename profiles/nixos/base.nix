{ lib, pkgs, ... }:

{
  boot = {
    initrd = {
      availableKernelModules = [
        "usbhid"
      ];
      kernelModules = [
        "dm-snapshot"
        "cryptd"
      ];
    };
    kernel.sysctl = {
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.src_valid_mark" = 1;
      "net.ipv4.ip_forward" = 1;
    };
    kernelPackages = pkgs.linuxPackages;
    kernelParams = [
      "rw"
      "loglevel=3"
      "skew_tick=1"
      "net.ifnames=0"
    ];
    loader = {
      grub.enable = false;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    supportedFilesystems = [
      "ext4"
      "vfat"
    ];
    tmp.cleanOnBoot = true;
  };
  console = {
    font = "eurlatgr";
    keyMap = lib.mkForce "us";
    useXkbConfig = false;
  };
  environment.systemPackages = with pkgs; [
    lm_sensors
    psmisc
    vim
  ];
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
    interfaces.eth0.wakeOnLan.enable = true;
    networkmanager = {
      enable = true;
      ensureProfiles = {
        profiles = {
          eth0 = {
            connection = {
              id = "eth0";
              type = "ethernet";
              interface-name = "eth0";
              autoconnect = true;
            };
            ipv4 = {
              method = "auto";
            };
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "auto";
            };
            ethernet = {
              wake-on-lan = 64;
            };
          };
        };
      };
    };
  };
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    optimise.automatic = true;
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://nixos-raspberrypi.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6CHFhJg8g5Q5T2NI3jNgQ8DxbIXGs6Zht7G7DH2Q3tn="
        "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };
  time = {
    hardwareClockInLocalTime = false;
    timeZone = "Europe/Istanbul";
  };
}
