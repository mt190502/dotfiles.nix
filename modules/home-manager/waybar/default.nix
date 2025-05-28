{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  pomobar-client = lib.getExe' config.services.pomobar.package "pomobar-client";
  wm =
    if cfg.prefered-wm == "sway" then
      "sway"
    else if cfg.prefered-wm == "hyprland" then
      "hypr"
    else
      throw "Unsupported window manager: ${cfg.prefered-wm}";
  home = config.home.homeDirectory;
in
{
  options.moduleopts.home-manager.waybar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "waybar";
    };
    weather_location = lib.mkOption {
      default = "Istanbul";
      type = lib.types.str;
      description = "location for weather";
    };
  };
  config = lib.mkIf cfg.waybar.enable {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "${cfg.prefered-wm}-session.target";
      };
      settings = {
        mainBar = {
          #################################################
          #### Bar configuration
          #################################################
          height = 27;
          position = "top";

          #################################################
          #### Modules
          #################################################
          modules-left = [
            "custom/space2"
            "sway/workspaces"
            "custom/space"
            "sway/window"
          ];
          modules-center = [
            "sway/mode"
            "custom/space"
            "mpd"
            "custom/space"
            "clock"
            "custom/space"
            "custom/weather"
          ];
          modules-right = [
            "tray"
            "custom/space"
            "memory"
            "custom/space"
            "idle_inhibitor"
            "custom/space"
            "sway/language"
            "custom/space"
            "network"
            "custom/space"
            "bluetooth"
            "custom/space"
            "pulseaudio"
            "custom/space"
            "custom/swaync"
            "custom/space"
            "custom/powermenu"
            "custom/space2"
          ];

          #################################################
          #### Module(s) configuration
          #################################################
          "sway/language" = {
            format = "{short} {variant}";
            on-click = ''${lib.getExe' config.wrapped.sway "swaymsg"} input "type:keyboard" xkb_switch_layout next'';
          };

          "sway/mode" = {
            format = ''<span style="italic">{}</span>'';
            tooltip = false;
          };

          "sway/scratchpad" = {
            format = "{icon} {count}";
            show-empty = false;
            format-icons = [
              ""
              ""
            ];
            tooltip = true;
            tooltip-format = "{app}: {title}";
          };

          "sway/window" = {
            format = "{}";
            max-length = 50;
            tooltip = false;
          };

          "sway/workspaces" = {
            format = "{}";
            format-icons = {
              focused = "";
              default = "";
            };
          };

          battery = {
            bat = "BAT0";
            interval = 60;
            states = {
              warning = 30;
              critical = 1;
            };
            format = "{icon} {capacity}%";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
            max-length = 2;
          };

          bluetooth = {
            format = "";
            format-connected = "";
            format-connected-battery = " {icon} {device_battery_percentage}%";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
          };

          clock = {
            format = "{:%a %d %b  %H:%M:%S}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "left";
              on-scroll = 1;
              format = {
                months = "<span color='#ffead3'><b>{}</b></span>";
                days = "<span color='#ecc6d9'><b>{}</b></span>";
                weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                today = "<span background='#ffffff' color='#000000'><b>{}</b></span>";
              };
            };
            interval = 1;
          };

          cpu = {
            interval = 1;
            format = " {max_frequency:0.2f}GHz | {usage}%";
            on-click = "${home}/.local/bin/program-toggler ${lib.getExe config.wrapped.alacritty} -T BTOP -e btop";
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };

          memory = {
            interval = 10;
            format = " {used:0.2f} / {total:0.0f} GB";
            on-click = "${home}/.local/bin/program-toggler ${lib.getExe config.wrapped.alacritty} -T BTOP -e btop";
          };

          mpd = {
            format = "{stateIcon} | {elapsedTime:%M:%S}/{totalTime:%M:%S} | {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}";
            format-disconnected = "MPD Off ";
            interval = 10;
            consume-icons = {
              on = " ";
            };
            random-icons = {
              on = " ";
            };
            repeat-icons = {
              on = "";
            };
            single-icons = {
              on = "1 ";
            };
            state-icons = {
              paused = "";
              playing = "";
              stopped = "";
            };
            tooltip-format = "{artist} - {album} - {title}";
            on-click = "${lib.getExe pkgs.mpc} toggle";
            on-click-middle = "${lib.getExe pkgs.mpc} stop";
            on-click-right = "${home}/.config/${wm}/scripts.d/ncmpcpp.sh";
            on-scroll-up = "${lib.getExe pkgs.mpc} volume +5";
            on-scroll-down = "${lib.getExe pkgs.mpc} volume -5";
          };

          network = {
            tooltip = false;
            format-wifi = "";
            format-ethernet = "";
            format-linked = " (No IP)";
            format-disconnected = "⚠ Disconnected";
            format-alt = "{essid} {ipaddr}/{cidr} ";
            on-click-right = "${home}/.local/bin/program-toggler ${lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor"}";
          };

          pulseaudio = {
            tooltip = false;
            format = "{icon} {volume}%  {format_source}";
            format-muted = "󰝟";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "󰋎";
              headset = "󰋎";
              phone = "";
              portable = "";
              car = "";
              default = [
                " "
                " "
                " "
              ];
            };
            scroll-step = 5;
            on-click = "${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-mute @DEFAULT_SINK@ toggle";
            on-click-middle = "${home}/.local/bin/program-toggler ${lib.getExe pkgs.pavucontrol}";
            on-click-right = "${lib.getExe' pkgs.pulseaudio "pactl"} set-source-mute @DEFAULT_SOURCE@ toggle";
            on-scroll-up = "${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume @DEFAULT_SINK@ +5%";
            on-scroll-down = "${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume @DEFAULT_SINK@ -5%";
            ignored-sinks = [ "Easy Effects Sink" ];
          };

          tray = {
            spacing = 5;
            show-passive-items = true;
          };

          ###################################################
          #### Other module(s)
          ###################################################
          "custom/dnd-mako" = {
            format = "{}";
            exec = "${home}/.local/bin/mako-dnd-toggle status";
            on-click = "${home}/.local/bin/mako-dnd-toggle toggle";
            return-type = "json";
            signal = 9;
          };

          "custom/fan" = {
            exec = "cat $(find /sys/devices/platform -iname '*fan1_input' 2>/dev/null)";
            format = "󰈐 {} RPM";
            tooltip = false;
            interval = 1;
          };

          "custom/pomobar" = {
            format = "{}";
            interval = 1;
            exec = "${pomobar-client} status";
            on-click = "${pomobar-client} pause";
            on-click-middle = "${pomobar-client} reset";
            on-click-right = "${pomobar-client} resume";
            return-type = "json";
          };

          "custom/powermenu" = {
            on-click = "${home}/.local/bin/program-toggler ${home}/.local/bin/powermenu";
            format = "";
            tooltip = false;
          };

          "custom/screenshot" = {
            on-click = "${home}/.local/bin/program-toggler ${home}/.local/bin/grimshot";
            format = "";
            tooltip = false;
          };

          "custom/space" = {
            format = " ";
            tooltip = false;
          };

          "custom/space2" = {
            format = "  ";
            tooltip = false;
          };

          "custom/swaync" = {
            tooltip = false;
            format = "{icon} {}";
            format-icons = {
              notification = "";
              none = "";
              dnd-notification = "";
              dnd-none = "";
              inhibited-notification = "";
              inhibited-none = "";
              dnd-inhibited-notification = "";
              dnd-inhibited-none = "";
            };
            return-type = "json";
            exec-if = "${lib.getExe' pkgs.swaynotificationcenter "swaync-client"}";
            exec = "${lib.getExe' pkgs.swaynotificationcenter "swaync-client"} -swb";
            on-click = "${lib.getExe' pkgs.swaynotificationcenter "swaync-client"} -t -sw";
            on-click-middle = "${lib.getExe' pkgs.systemd "systemctl"} --user restart swaync"; # temporarily fix for swaync bug
            on-click-right = "${lib.getExe' pkgs.swaynotificationcenter "swaync-client"} -d -sw";
            escape = true;
          };

          "custom/weather" = {
            format = "{}";
            interval = 3600;
            exec = "${lib.getExe pkgs.curl} -s 'https://wttr.in/${cfg.waybar.weather_location}?format=1' | sed 's/ //1'";
            exec-if = "ping wttr.in -c1";
            on-click = "${home}/.local/bin/program-toggler ${lib.getExe config.wrapped.alacritty} -T wttr.in -e sh -c '${lib.getExe pkgs.curl} https://wttr.in/${cfg.waybar.weather_location}; read'";
          };
        };
      };
      style = with config.lib.stylix.colors.withHashtag; ''
      * {
          border-radius: 5px;
          font-family: ${config.stylix.fonts.sansSerif.name}, Arial, sans-serif;
          font-size: ${builtins.toString (config.stylix.fonts.sizes.applications + 2)}px;
          min-height: 0;
      }
      
      #tray,
      #workspaces,
      widget label {
          background-color: ${base00};
          color: ${base05};
          margin: 6px 0px 0px 0px;
          padding: 0px 7px 0px 7px;
      }
      
      #custom-space,
      #custom-space2,
      #workspaces button,
      #workspaces button label,
      window#waybar,
      window#waybar.empty #window label {
          background-color: transparent;
          margin: 0px 0px 0px 0px;
          padding: 0px 1px 0px 1px;
      }
      
      #custom-space,
      #custom-space2 {
          background-color: transparent;
          padding: 0px 0px 0px 0px;
      }

      #workspaces button,
      #workspaces button label {
	        margin: 0px -2px 0px -2px;
      }

      box#tray window.popup * {
          background-color: ${base00};
          color: ${base05};
      }
      '';
    };
  };
}
