{ pkgs, ... }:

{
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = false;
  services.power-profiles-daemon.enable = false;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
  ]; 
}