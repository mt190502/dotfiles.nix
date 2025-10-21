{ config, lib, ... }:

let
  cfg = config.moduleopts.nixos.fontconfig;
in
{
  config = lib.mkIf cfg.enable {
    fonts.fontconfig = {
      enable = true;
      antialias = true;
      cache32Bit = true;
      hinting = {
        enable = true;
        autohint = true;
        style = "slight";
      };
      includeUserConf = true;
      subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };
      useEmbeddedBitmaps = true;
    };
  };
}
