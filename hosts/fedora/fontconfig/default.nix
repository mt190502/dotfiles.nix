{ config, lib, ... }:

{
  options.pkgconfig.fontconfig = {
    enable = lib.mkEnableOption "Enable fontconfig configuration.";
  };

  config.xdg.configFile."fontconfig/fonts.conf".text = lib.mkIf config.pkgconfig.fontconfig.enable ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
        <match target="font">
            <edit name="antialias" mode="assign">
                <bool>true</bool>
            </edit>
            <edit name="hinting" mode="assign">
                <bool>true</bool>
            </edit>
            <edit name="hintstyle" mode="assign">
                <const>hintslight</const>
            </edit>
            <edit name="rgba" mode="assign">
                <const>rgb</const>
            </edit>
            <edit name="autohint" mode="assign">
                <bool>true</bool>
            </edit>
            <edit name="lcdfilter" mode="assign">
                <const>lcddefault</const>
            </edit>
            <edit name="dpi" mode="assign">
                <double>96</double>
            </edit>
            <test name="weight" compare="more">
                <const>medium</const>
            </test>
        </match>
    </fontconfig>
  '';
}
