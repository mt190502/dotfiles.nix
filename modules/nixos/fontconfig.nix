{ pkgs, inputs, ... }:

{
  fonts = {
    packages = with pkgs; [
      eb-garamond
      inputs.self.packages.${stdenv.hostPlatform.system}.msfonts
    ];
    fontconfig = {
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
