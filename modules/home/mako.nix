{ config, lib, ... }:

{
  config = {
    preferences.notifier = lib.mkDefault "mako";
    services.mako = with config.stylix.customColors.withHashtag; {
      enable = true;
      settings = {
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

        "mode-dnd" = {
          invisible = true;
        };
        "urgency=high" = {
          border-color = urgent;
          default-timeout = 0;
        };
      };
    };
  };
}
