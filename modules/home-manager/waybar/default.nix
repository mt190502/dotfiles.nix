{
  config,
  lib,
  pkgs,
  system,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  home = config.home.homeDirectory;
  pomobar-client = lib.getExe' config.services.pomobar.package "pomobar-client";
  term =
    title: command:
    (
      if cfg.preferred.terminal == "alacritty" then
        lib.getExe pkgs.alacritty + " -T " + title + " -e " + command
      else if cfg.preferred.terminal == "foot" then
        (lib.getExe' pkgs.foot "footclient") + " -T ${title} ${command}"
      else
        throw "Unsupported terminal: ${cfg.preferred.terminal}"
    );
  wm =
    if cfg.preferred.wm == "sway" then
      "sway"
    else if cfg.preferred.wm == "hyprland" then
      "hypr"
    else
      throw "Unsupported window manager: ${cfg.preferred.wm}";
in
{
  options.moduleopts.home-manager.waybar = {
    enableLaptopOpts = lib.mkEnableOption "laptop";
    weather_location = lib.mkOption {
      default = "Istanbul";
      type = lib.types.str;
      description = "location for weather";
    };
  };
  config = lib.mkIf (cfg.preferred.bar == "waybar" && lib.hasSuffix "linux" system) {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "${cfg.preferred.wm}-session.target";
      };
      settings =
        let
          curl = lib.getExe pkgs.curl;
          mpc = lib.getExe' pkgs.mpc "mpc";
          nmeditor = lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor";
          pactl = lib.getExe' pkgs.pulseaudio "pactl";
          pavucontrol = lib.getExe pkgs.pavucontrol;
          swaymsg = lib.getExe' pkgs.sway "swaymsg";
          swaync = lib.getExe' pkgs.swaynotificationcenter "swaync-client";
          systemctl = lib.getExe' pkgs.systemd "systemctl";
        in
        {
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
              "${cfg.preferred.wm}/workspaces"
              "custom/space"
              "${cfg.preferred.wm}/window"
            ];

            modules-center = (if wm == "sway" then [ "sway/mode" ] else [ ]) ++ [
              "custom/space"
              "mpd"
              "custom/space"
              "clock"
              "custom/space"
              "custom/weather"
            ];

            modules-right = [
              "group/tray-expander"
              "custom/space"
              "memory"
              "custom/space"
              "idle_inhibitor"
              "custom/space"
              "${cfg.preferred.wm}/language"
              "custom/space"
              "network"
              "custom/space"
              "bluetooth"
            ]
            ++ (lib.optional cfg.waybar.enableLaptopOpts "custom/space")
            ++ (lib.optional cfg.waybar.enableLaptopOpts "battery")
            ++ [
              "custom/space"
              "pulseaudio"
              "custom/space"
            ]
            ++ (
              if cfg.preferred.notifier == "mako" then
                [
                  "custom/dnd-mako"
                ]
              else if cfg.preferred.notifier == "swaync" then
                [
                  "custom/swaync"
                ]
              else
                throw "Unsupported notifier: ${cfg.preferred.notifier}"
            )
            ++ [
              "custom/space"
              "custom/powermenu"
              "custom/space2"
            ];

            #################################################
            #### Module(s) configuration
            #################################################
            "group/tray-expander" = {
              orientation = "inherit";
              drawer = {
                transition-duration = 600;
              };
              modules = [
                "custom/tray-expand-icon"
                "tray"
              ];
            };

            "hyprland/language" = {
              format = "{short} {variant}";
              on-click = ''${swaymsg} input "type:keyboard" xkb_switch_layout next'';
            };

            "hyprland/window" = {
              format = "{}";
              max-length = 50;
              tooltip = false;
            };

            "hyprland/workspaces" = {
              format = "{icon}";
              format-icons = {
                active = "";
                default = "";
              };
            };

            "sway/language" = {
              format = "{short} {variant}";
              on-click = ''${swaymsg} input "type:keyboard" xkb_switch_layout next'';
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
              interval = 30;
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
              on-click = "${home}/.local/bin/program-toggler ${term "BTOP" "btop"}";
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
              on-click = "${home}/.local/bin/program-toggler ${term "BTOP" "btop"}";
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
              on-click = "${mpc} toggle";
              on-click-middle = "${mpc} stop";
              on-click-right = "${home}/.config/${wm}/scripts.d/media.sh";
              on-scroll-up = "${mpc} volume +5";
              on-scroll-down = "${mpc} volume -5";
            };

            network = {
              tooltip = false;
              format-wifi = "";
              format-ethernet = "";
              format-linked = " (No IP)";
              format-disconnected = "⚠ Disconnected";
              format-alt = "{essid} {ipaddr}/{cidr} ";
              on-click-right = "${home}/.local/bin/program-toggler ${nmeditor}";
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
              on-click = "${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
              on-click-middle = "${home}/.local/bin/program-toggler ${pavucontrol}";
              on-click-right = "${pactl} set-source-mute @DEFAULT_SOURCE@ toggle";
              on-scroll-up = "${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
              on-scroll-down = "${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
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
              format = "{icon} {text}";
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
              exec-if = "${swaync}";
              exec = "${swaync} -swb";
              on-click = "${swaync} -t -sw";
              on-click-middle = "${systemctl} --user restart swaync"; # temporarily fix for swaync bug
              on-click-right = "${swaync} -d -sw";
              escape = true;
            };

            "custom/tray-expand-icon" = {
              format = "";
              tooltip = false;
            };

            "custom/weather" = {
              format = "{}";
              interval = 3600;
              exec = "${curl} -s 'https://wttr.in/${cfg.waybar.weather_location}?format=1' | sed 's/ //1'";
              exec-if = "ping wttr.in -c1";
              on-click = "${home}/.local/bin/program-toggler ${term "wttr.in" "sh -c '${curl} https://wttr.in/${cfg.waybar.weather_location}; read'"}";
            };
          };
        };
      style = with config.stylix.customColors.withHashtag; ''
              * {
                border-radius: 5px;
                font-family: ${config.stylix.fonts.sansSerif.name}, Arial, sans-serif;
                font-size: ${builtins.toString (config.stylix.fonts.sizes.applications + 2)}px;
                min-height: 0;
              }

              #tray-expander:hover #custom-tray-expand-icon {
                background-color: transparent;
                color: transparent;
              }

              #tray,
              #workspaces,
              widget label {
                background-color: ${background};
                color: ${text};
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
                background-color: ${background};
                color: ${text};
              }
      '';
    };
  };
}
