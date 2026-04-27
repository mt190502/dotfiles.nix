{ config, pkgs, ... }:

{
  services.swaync = {
    enable = true;
    settings = {
      "$schema" = "${pkgs.swaynotificationcenter}/etc/xdg/swaync/configSchema.json";
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
      notification-icon-size = 64;
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
      widgets = [
        "title"
        "mpris"
        "dnd"
        "notifications"
      ];
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
    style = with config.stylix.customColors.withHashtag; ''
      * {
        border-radius: 0;
        font-family: "${config.stylix.fonts.sansSerif.name}";
        font-size: ${builtins.toString (config.stylix.fonts.sizes.applications + 3)}px;
        color: ${text};
      }

      .close-button {
        background: ${background};
        color: ${text};
        padding: 0;
        border: 0;
        min-width: 24px;
        min-height: 24px;
      }

      .close-button:hover {
        background: ${urgent};
        color: ${background};
      }

      .control-center-list .notification:hover,
      .notification-action:hover,
      .notification-default-action:hover {
        background: ${border};
        transition: none;
      }

      .control-center-clear-all,
      .control-center-dnd,
      .inline-reply-button:not(:disabled),
      .inline-reply-entry,
      .notification-group-close-all-button,
      .notification-group-collapse-button {
        background: ${background};
        border: 3px solid ${border};
      }

      .control-center-dnd:checked {
        background: ${border};
      }

      .control-center,
      .floating-notification {
        background: ${background};
        border: 5px solid ${border};
      }

      .inline-reply-button,
      .widget-dnd > switch:checked {
        background: ${border};
        border: 3px solid ${border};
      }

      .linked > .text-button:first-child {
        border-right: 2.5px solid ${border};
      }

      .linked > .text-button:last-child {
        border-left: 2.5px solid ${border};
      }

      .linked > .text-button:not(:first-child):not(:last-child) {
        border-left: 2.5px solid ${border};
        border-right: 2.5px solid ${border};
      }

      .linked > .text-button:only-child {
        border: 5px solid ${border};
        border-top: 0;
      }

      .notification-action {
        background: ${background};
        color: ${text};
        padding: 0;
      }

      .notification-alt-actions {
        padding: 0;
      }

      .notification {
        padding: 0;
        background: ${border};
      }

      .notification-content {
        background: ${background};
        border: 5px solid ${background};
      }

      .notification-group {
        background: ${background};
      }

      animatedlistitem {
        padding-top: 5px;
      }

      .widget-mpris-player,
      .widget-mpris-album-art {
        border: 3px solid ${border};
      }
    '';
  };
}
