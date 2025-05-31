{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
in
{
  options.moduleopts.home-manager.gtklock = {
    systemd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable systemd service for gtklock";
    };
  };
  config = lib.mkIf (cfg.prefered-lock-app == "gtklock") {
    xdg.configFile."gtklock/config.ini".text = ''
      [main]
      modules=${pkgs.gtklock-playerctl-module}/lib/gtklock/playerctl-module.so
      time-format=  %I:%M %p

      [playerctl]
      art-size=64
      position=bottom-center
    '';
    xdg.configFile."gtklock/style.css".text = with config.lib.stylix.colors.withHashtag; ''
      @keyframes fadeIn {
        from {
          opacity: 0;
        }

        to {
          opacity: 1;
        }
      }

      * {
        all: unset;
        transition: all 150ms ease-in-out;
      }

      window {
        background-color: ${base00};
        animation: fadeIn 400ms ease;
      }

      #window-box,
      #playerctl-revealer>box,
      #powerbar-revealer>box {
        color: ${base05};
        background-color: ${base00};     
        border: 2px solid ${base0D};
        border-radius: 12px;
        padding: 2em 3em;     
      }

      #playerctl-revealer>box,
      #powerbar-revealer>box {
        padding: 0.7em;
        margin: 0.8em 0;
        background-color: ${base00};
      }

      #clock-label {
        min-width: 320px;
        color: ${base0D};
        font-weight: 500;
        font-size: 28pt;
        padding: 8px 16px;
        margin-bottom: 12px;     
        letter-spacing: 0.5px;
      }

      .image-button {
        padding: 0.8em;     
        background-color: transparent;
      }

      .image-button:hover {
        background-color: alpha(${base05}, 0.05);
      }

      #user-name {
        font-size: 18pt;
      }

      #input-field {     
        padding: 10px 12px;
        background-color: ${base00};
        border: 2px solid ${base0D};
        border-radius: 16px;
        margin: 10px 0;
      }

      #input-field:focus {
        box-shadow: 0 0 0 2px alpha(${base05}, 0.9);
      }

      #warning-label,
      #error-label,
      #unlock-button {
        margin: 15px 0;
        padding: 10px 24px;     
      }

      #unlock-button {
        background-color: ${base0D};
        border-radius: 12px;
        color: ${base00};
        font-weight: 500;
      }

      #unlock-button:hover {
        background-color: alpha(${base05}, 0.9);
      }

      #error-label {
        color: ${base0C};
      }
    '';
    systemd.user.services = lib.mkIf cfg.gtklock.systemd.enable {
      session-lock = {
        Unit = {
          Description = "Session Lock";
          Before = [
            "suspend.target"
            "sleep.target"
            "hibernate.target"
          ];
          Wants = [
            "suspend.target"
            "sleep.target"
            "hibernate.target"
          ];
        };
        Service = {
          Type = "forking";
          ExecStart = "gtklock -d";
        };
        Install = {
          WantedBy = [
            "sleep.target"
            "suspend.target"
            "hibernate.target"
          ];
        };
      };
    };
  };
}
