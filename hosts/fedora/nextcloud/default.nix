{ config, lib, ... }:

{
  options.pkgconfig.nextcloud-client = {
    enable = lib.mkEnableOption "Enable Nextcloud client";
  };
  config.services.nextcloud-client = {
    enable = config.pkgconfig.nextcloud-client.enable;
    package = config.wrappedPkgs.nextcloud-client;
    startInBackground = true;
  };
}