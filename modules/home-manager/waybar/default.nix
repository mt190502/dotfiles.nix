{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.waybar;
in
{
  options.moduleopts.waybar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Waybar";
    };
    weather_location = lib.mkOption {
      default = "Istanbul";
      type = lib.types.str;
      description = "The location for the weather module.";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      package = config.wrapped.waybar;

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
            "custom/space"
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
            "custom/space"
          ];

          #################################################
          #### Module(s) configuration
          #################################################
          "sway/language" = {
            format = "{short} {variant}";
            on-click = ''${config.wrapped.sway}/bin/swaymsg input "type:keyboard" xkb_switch_layout next'';
          };

          "sway/mode" = {
            format = ''<span style="italic">{}</span>'';
            tooltip = false;
          };

          "sway/scratchpad" = {
            format = "{icon} {count}";
            show-empty = false;
            format-icons = [
              ""
              "<U+F2D2>"
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
            on-click = "${config.home.homeDirectory}/.config/sway/scripts.d/programtoggle.sh ${lib.getExe config.wrapped.alacritty} -T BTOP -e btop";
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
            on-click = "${config.home.homeDirectory}/.config/sway/scripts.d/programtoggle.sh ${lib.getExe config.wrapped.alacritty} -T BTOP -e btop";
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
            on-click-right = "${config.home.homeDirectory}/.config/sway/scripts.d/ncmpcpp.sh";
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
            on-click-right = "${config.home.homeDirectory}/.config/sway/scripts.d/programtoggle.sh ${lib.getExe config.wrapped.alacritty} -T nmtui -e nmtui";
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
            on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
            on-click-middle = "${config.home.homeDirectory}/.config/sway/scripts.d/programtoggle.sh ${pkgs.pavucontrol}/bin/pavucontrol";
            on-click-right = "${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            on-scroll-up = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
            on-scroll-down = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
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
            exec = "${config.home.homeDirectory}/.config/sway/scripts.d/dnd.sh status";
            on-click = "${config.home.homeDirectory}/.config/sway/scripts.d/dnd.sh";
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
            exec = "${config.home.homeDirectory}/.local/bin/pomobar-client status";
            on-click = "${config.home.homeDirectory}/.local/bin/pomobar-client pause";
            on-click-middle = "${config.home.homeDirectory}/.local/bin/pomobar-client reset";
            on-click-right = "${config.home.homeDirectory}/.local/bin/pomobar-client resume";
            return-type = "json";
          };

          "custom/powermenu" = {
            on-click = "${config.home.homeDirectory}/.config/sway/scripts.d/programtoggle.sh ${config.home.homeDirectory}/.config/sway/scripts.d/powermenu.sh --lockmenu";
            format = "";
            tooltip = false;
          };

          "custom/screenshot" = {
            on-click = "${config.home.homeDirectory}/.config/sway/scripts.d/screenshot.sh";
            format = "";
            tooltip = false;
          };

          "custom/space" = {
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
            exec-if = "${pkgs.swaynotificationcenter}/bin/swaync-client";
            exec = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";
            on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
            on-click-middle = "${pkgs.systemd}/bin/systemctl --user restart swaync"; # temporarily fix for swaync bug
            on-click-right = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
            escape = true;
          };

          "custom/weather" = {
            format = "{}";
            interval = 3600;
            exec = "${lib.getExe pkgs.curl} -s 'https://wttr.in/${cfg.weather_location}?format=1' | sed 's/ //1'";
            exec-if = "ping wttr.in -c1";
            on-click = "${config.home.homeDirectory}/.config/sway/scripts.d/programtoggle.sh ${lib.getExe config.wrapped.alacritty} -T wttr.in -e sh -c '${lib.getExe pkgs.curl} https://wttr.in/${cfg.weather_location}; read'";
          };
        };
      };

      style = ''
        @define-color activeColor    ${config.colors.activeColor};
        @define-color inactiveColor  ${config.colors.inactiveColor};
        @define-color inactiveColor2 ${config.colors.inactiveColor2};
        @define-color urgentColor    ${config.colors.urgentColor};
        @define-color textColor      ${config.colors.textColor};


        * {
        	border-radius: 5px;
        	font-family: ${config.stylix.fonts.sansSerif.name}, Arial, sans-serif;
        	font-size: ${builtins.toString (config.stylix.fonts.sizes.applications + 3)}px;
        	min-height: 0;
        }

        box.horizontal #tray widget window menu menuitem *,
        window#waybar,
        window#waybar.empty #window label {
        	background-color: transparent;
        }

        #tray,
        #workspaces,
        widget label:not(#custom-space) {
        	background-color: @activeColor;
        	color: @textColor;
        	margin: 6px 0px 2px 0px;
        	padding: 0px 10px 0px 10px;
        }

        #workspaces button,
        #workspaces button label {
        	background-color: @activeColor;
        	color: @textColor;
        	margin: 0px 0px 0px 0px;
        	padding: 0px 1px 0px 1px;
        }
      '';
    };
  };
}
