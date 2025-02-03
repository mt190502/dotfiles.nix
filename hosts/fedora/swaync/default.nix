{ config, pkgs, lib, ... }:

{
  options.pkgconfig.swaync = { enable = lib.mkEnableOption "Enable swaync"; };
  config.services.swaync = {
    enable = config.pkgconfig.swaync.enable;
    package = pkgs.swaynotificationcenter;
    settings = {
      "$schema" =
        "${pkgs.swaynotificationcenter}/etc/xdg/swaync/configSchema.json";
      control-center-height = 500;
      control-center-layer = "top";
      control-center-margin-bottom = 5;
      control-center-margin-left = 0;
      control-center-margin-right = 5;
      control-center-margin-top = 5;
      control-center-positionX = "right";
      control-center-positionY = "center";
      control-center-width = 500;
      cssPriority = "application";
      fit-to-screen = true;
      hide-on-action = false;
      hide-on-clear = true;
      image-visibility = "when-available";
      keyboard-shortcuts = true;
      layer = "overlay";
      layer-shell = true;
      notification-2fa-action = true;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      notification-icon-size = 40;
      notification-inline-replies = true;
      notification-visibility = { };
      notification-window-width = 400;
      positionX = "right";
      positionY = "top";
      relative-timestamps = true;
      script-fail-notify = true;
      scripts = { };
      timeout = 30;
      timeout-critical = 0;
      timeout-low = 5;
      transition-time = 200;
      widgets = [ "title" "mpris" "dnd" "notifications" ];
      widget-config = {
        mpris = {
          image-size = 100;
        };
        title = {
          text = "Notifications";
          button-text = "󰎟  Clear";
          clear-all-button = true;
        };
        volume = {
          label = " ";
          show-per-app = true;
          show-per-app-icon = true;
          show-per-app-label = true;
        };
      };
    };
    style = ''
      @define-color activeColor     ${config.colors.activeColor};
      @define-color backgroundColor ${config.colors.backgroundColor};
      @define-color inactiveColor   ${config.colors.inactiveColor};
      @define-color inactiveColor2  ${config.colors.inactiveColor2};
      @define-color urgentColor     ${config.colors.urgentColor};
      @define-color textColor       ${config.colors.textColor};

      * {
        border-radius: 0;
        font-family: ${config.stylix.fonts.sansSerif.name}, FontAwesome5Brands, FontAwesome5Free, Arial, sans-serif;
      	font-size: ${
         builtins.toString (config.stylix.fonts.sizes.applications + 3)
       }px;
        color: @textColor;
      }

      .close-button {
        background: @backgroundColor;
        padding: 0;
        border: 0;
        min-width: 24px;
        min-height: 24px;
      }

      .close-button:hover,
      .control-center-list .notification:hover,
      .notification-action:hover,
      .notification-default-action:hover {
        background: initial;
        transition: none;
      }

      .control-center-clear-all,
      .control-center-dnd,
      .inline-reply-button:not(:disabled),
      .inline-reply-entry,
      .notification-group-close-all-button,
      .notification-group-collapse-button {
        background: @backgroundColor;
        border: 3px solid @activeColor;
      }

      .control-center-dnd:checked {
        background: @activeColor;
      }

      .control-center,
      .floating-notification {
        background: @backgroundColor;
        border: 5px solid @activeColor;
      }

      .inline-reply-button,
      .widget-dnd > switch:checked {
        background: @activeColor;
        border: 3px solid @activeColor;
      }

      .linked > .text-button:first-child {
        border-right: 2.5px solid @activeColor;
      }

      .linked > .text-button:last-child {
        border-left: 2.5px solid @activeColor;
      }

      .linked > .text-button:not(:first-child):not(:last-child) {
        border-left: 2.5px solid @activeColor;
        border-right: 2.5px solid @activeColor;
      }

      .linked > .text-button:only-child {
        border: 5px solid @activeColor;
        border-top: 0;
      }

      .notification-action {
        background: @backgroundColor;
        padding: 0;
        border: 5px solid @activeColor;
        border-top: 0;
      }

      .notification-background,
      .notification {
        padding: 0;
        background: @activeColor;
        border: 0;
      }

      .notification-content {
        background: @backgroundColor;
        border: 5px solid @activeColor;
      }

      .notification-default-action {
        padding: 0;
        border: 2px solid @backgroundColor;
      }

      .notification-row {
        padding: 15px;
        background: none;
        border: 0;
      }

      .widget-mpris-player,
      .widget-mpris-album-art {
        border: 3px solid @activeColor;
      }
    '';
  };
}
