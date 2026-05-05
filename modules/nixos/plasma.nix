{ pkgs, ... }:

{
  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = false;
    power-profiles-daemon.enable = false;
  };
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
  ];
}
