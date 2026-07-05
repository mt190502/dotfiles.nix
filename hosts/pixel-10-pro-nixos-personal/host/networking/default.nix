{ lib, ... }:

{
  networking = {
    hostName = "pixel-190502";
    interfaces.eth0.wakeOnLan.enable = lib.mkForce false;
    networkmanager.enable = lib.mkForce false;
    nftables.enable = lib.mkForce false;
    firewall.enable = lib.mkForce false;
  };
}
