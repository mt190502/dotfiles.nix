{ pkgs, ... }:

with pkgs;
{
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = waydroid-nftables;
  environment.systemPackages = [
    waydroid-helper
    wl-clipboard
  ];
}
