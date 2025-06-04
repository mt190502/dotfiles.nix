{ config, lib, ... }:

let
  makoOpacity = lib.toHexString (((builtins.ceil (config.stylix.opacity.popups * 100)) * 255) / 100);
  cfg = config.moduleopts.home-manager.mako;
in
{
  options.moduleopts.home-manager.mako = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "mako";
    };
  };
  config = lib.mkIf cfg.enable {
    services.mako = with config.stylix.customColors.withHashtag; {
      enable = true;
      backgroundColor = background + makoOpacity;
      borderColor = active;
      textColor = text;
      progressColor = "over ${active}";
      borderRadius = 0;
      borderSize = 5;
      defaultTimeout = 10000;
      font = "${config.stylix.fonts.sansSerif.name} ${builtins.toString config.stylix.fonts.sizes.applications}";
      ignoreTimeout = true;
      layer = "overlay";
      margin = "16";
      maxIconSize = 64;
      sort = "-time";
      extraConfig = ''
        [urgency=high]
        border-color=${urgent}
        default-timeout=0

        [mode=dnd]
        invisible=1
      '';
    };
  };
}
