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
    kernelPackages = pkgs.linuxPackages_6_18;
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
  environment.systemPackages = with pkgs; [ ];
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
  time = {
    hardwareClockInLocalTime = false;
    timeZone = "Europe/Istanbul";
  };
}
