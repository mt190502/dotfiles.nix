{ config, ... }:

{
  services.nextcloud-client = {
    enable = true;
    package = config.wrappedPkgs.nextcloud-client;
    startInBackground = true;
  };
}
