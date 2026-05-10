{ lib, ... }:

{
  networking = {
    hostName = "raspberry-190502";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };
}
