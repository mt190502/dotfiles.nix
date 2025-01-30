{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.pkgconfig.waybar = {
    enable = lib.mkEnableOption "Enable waybar configuration.";
    weather_location = lib.mkOption {
      default = "Istanbul";
      type = lib.types.str;
      description = "The location for the weather module.";
    };
  };
  config.programs.waybar = {
    enable = config.pkgconfig.waybar.enable;
    package = config.wrappedPkgs.waybar;

    settings = {
      mainBar = {
        ################################################
        ##
        #### Bar configuration
        ##
        ################################################
        height = 27;
        position = "top";

        ################################################
        ##
        #### Modules
        ##
        ################################################
        modules-left = [
          "custom/space"
          "sway/workspaces"
          "custom/space"
          "sway/window"
        ];
        modules-center = [
          "sway/mode"
          "custom/space"
          "custom/pomobar"
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
          "custom/dnd"
          "custom/space"
          "custom/powermenu"
          "custom/space"
        ];

        ################################################
        ##
        #### Module(s) configuration
        ##
        ################################################
        "sway/workspaces" = {
          format = "{}";
          format-icons = {
            focused = "";
            default = "";
          };
        };

        "sway/mode" = {
          format = ''<span style="italic">{}</span>'';
          tooltip = false;
        };

        "sway/language" = {
          format = "{short} {variant}";
          on-click = ''${pkgs.sway}/bin/swaymsg input "type:keyboard" xkb_switch_layout next'';
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

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };

        tray = {
          spacing = 5;
          show-passive-items = true;
        };

        cpu = {
          interval = 1;
          format = " {max_frequency:0.2f}GHz | {usage}%";
          on-click = "${lib.getExe config.programs.alacritty.package} -e btop";
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

        memory = {
          interval = 10;
          format = " {used:0.2f} / {total:0.0f} GB";
          on-click = "${lib.getExe config.programs.alacritty.package} -e btop";
        };

        network = {
          tooltip = false;
          format-wifi = "";
          format-ethernet = "";
          format-linked = " (No IP)";
          format-disconnected = "⚠  Disconnected";
          format-alt = "{essid} {ipaddr}/{cidr} ";
          on-click-right = "${lib.getExe config.programs.alacritty.package} msg create-window -T nmtui -e nmtui";
        };

        pulseaudio = {
          tooltip = false;
          format = "{icon} {volume}%  {format_source}";
          format-muted = "";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
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
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          on-click-right = "$HOME/.config/sway/scripts.d/programtoggle.sh pavucontrol";
          on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
          on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
          ignored-sinks = [ "Easy Effects Sink" ];
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

        ##################################################
        ##
        #### Other module(s)
        ##
        ##################################################
        "custom/space" = {
          format = "  ";
          tooltip = false;
        };

        "custom/fan" = {
          exec = "cat $(find /sys/devices/platform -iname '*fan1_input' 2>/dev/null)";
          format = "  {} RPM";
          tooltip = false;
          interval = { };
        };

        "custom/powermenu" = {
          on-click = "$HOME/.config/sway/scripts.d/programtoggle.sh $HOME/.config/sway/scripts.d/powermenu.sh --lockmenu";
          format = "";
          tooltip = false;
        };

        "custom/screenshot" = {
          on-click = "$HOME/.config/sway/scripts.d/screenshot.sh";
          format = "";
          tooltip = false;
        };

        "custom/dnd" = {
          format = "{}";
          interval = 1;
          exec = "$HOME/.config/sway/scripts.d/dnd.sh status";
          on-click = "$HOME/.config/sway/scripts.d/dnd.sh";
          return-type = "json";
        };

        "custom/weather" = {
          format = "{}";
          interval = 3600;
          exec = "curl -s 'https://wttr.in/${config.pkgconfig.waybar.weather_location}?format=1' | sed 's/ //1'";
          exec-if = "ping wttr.in -c1";
          on-click = "${lib.getExe config.programs.alacritty.package} msg create-window -T wttr.in -e sh -c 'curl https://wttr.in/Istanbul; read'";
        };

        "custom/pomobar" = {
          format = "{}";
          interval = 1;
          exec = "$HOME/scripts/pomobar-client status";
          on-click = "$HOME/scripts/pomobar-client pause";
          on-click-middle = "$HOME/scripts/pomobar-client reset";
          on-click-right = "$HOME/scripts/pomobar-client resume";
          return-type = "json";
        };

        "custom/vpn" = {
          format = "{}";
          interval = 1;
          exec = "$HOME/scripts/togglevpn stat";
          on-click = "$HOME/scripts/togglevpn sm";
          on-click-right = "$HOME/scripts/togglevpn tm";
          return-type = "json";
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
      	font-family: ${config.stylix.fonts.sansSerif.name}, FontAwesome5Brands, FontAwesome5Free, Arial, sans-serif;
      	font-size: ${builtins.toString (config.stylix.fonts.sizes.applications + 3)}px;
      	min-height: 0;
      }

      window#waybar {
      	background-color: transparent;
      }

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

      box.horizontal #tray widget window menu menuitem * {
      	background-color: transparent;
      }
    '';
  };
}
