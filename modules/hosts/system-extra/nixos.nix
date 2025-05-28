{ config, lib, ... }:

let
  cfg = config.moduleopts.nixos.system-extra;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      dconf.enable = true;
      fish.enable = true;
      system-config-printer.enable = true;
    };
    services = {
      blueman.enable = true;
      gnome.gnome-keyring.enable = true;
      gvfs.enable = true;
      logrotate.checkConfig = false;
      smartd.enable = true;
      zram-generator = {
        enable = true;
        settings = {
          zram0 = {
            compression-algorithm = "zstd";
            zram-size = "ram";
          };
        };
      };
    };
  };
}
