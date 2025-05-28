{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager.swaynag;
in
{
  options.moduleopts.home-manager.swaynag = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "swaynag";
    };
  };
  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway.swaynag = {
      enable = true;
      settings = with config.lib.stylix.colors.withHashtag; {
        "theme" = {
          background = "${base00}00";
          border = "${base00}";
          border-bottom = "${base05}00";
          button-background = "${base00}";
          text = "${base00}";
          button-text = "${base05}";
          border-bottom-size = "0";
          message-padding = "5";
          details-background = "${base00}00";
          details-border-size = "0";
          button-border-size = "3";
          button-gap = "5";
          button-dismiss-gap = "10";
          button-margin-right = "10";
          button-padding = "5";
          font = "${config.stylix.fonts.sansSerif.name} ${builtins.toString config.stylix.fonts.sizes.applications}";
        };
      };
    };
  };
}
