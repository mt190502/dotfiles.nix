{
  config,
  lib,
  ...
}:

let
  cfg = config.moduleopts.nixos.fontconfig;
in
{
  config = lib.mkIf cfg.enable {
    fonts.fontconfig = {
      enable = true;
      antialias = true;
      cache32Bit = true;
      hinting.autohint = true;
      hinting.enable = true ;
      hinting.style = "slight";
      includeUserConf = true;
      subpixel.lcdfilter = "default";
      subpixel.rgba = "rgb";
      useEmbeddedBitmaps = true;
    };
  };
}
