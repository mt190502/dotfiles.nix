{
  config,
  lib,
  system,
  ...
}:

let
  cfg = config.moduleopts.home-manager.fontconfig;
in
{
  options.moduleopts.home-manager.fontconfig = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable fontconfig configuration for Home Manager.";
    };
  };
  config = lib.mkIf (cfg.enable) {
    fonts.fontconfig.enable = true;
    xdg.configFile = lib.mkIf (lib.hasSuffix "linux" system) {
      "fontconfig/fonts.conf".text = ''
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
            </match>
            <match target="font">
                <test name="weight" compare="more">
                    <const>medium</const>
                </test>
                <edit name="autohint" mode="assign">
                    <bool>true</bool>
                </edit>
            </match>
        </fontconfig>
      '';
      "fontconfig/conf.d/52-hm-default-fonts.conf".text = lib.mkForce ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
        </fontconfig>
      '';
    };
  };
}
