{ config, lib, ... }:

{
  options.pkgconfig.waybar = {
    enable = lib.mkEnableOption "Enable waybar configuration.";
  };
  config.programs.waybar = {
    enable = config.pkgconfig.waybar.enable;

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
          on-click = ''swaymsg input "type:keyboard" xkb_switch_layout next'';
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
          on-click = "$HOME/.config/sway/scripts.d/programtoggle.sh kitty -e htop";
        };

        clock = {
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
          format = "{:%a %d %b  %H:%M:%S}";
          interval = 1;
        };

        memory = {
          interval = 10;
          format = " {used:0.2f} / {total:0.0f} GB";
          on-click = "$HOME/.config/sway/scripts.d/programtoggle.sh kitty -e htop";
        };

        network = {
          tooltip = false;
          format-wifi = "";
          format-ethernet = "";
          format-linked = " (No IP)";
          format-disconnected = "⚠  Disconnected";
          format-alt = "{essid} {ipaddr}/{cidr} ";
          on-click-right = "$HOME/.config/sway/scripts.d/programtoggle.sh alacritty msg create-window -T nmtui -e nmtui";
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
          on-click = "~/.config/sway/scripts.d/screenshot.sh";
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
          exec = "curl -s 'https://wttr.in/Istanbul?format=1' | sed 's/ //1'";
          exec-if = "ping wttr.in -c1";
          on-click = "$HOME/.config/sway/scripts.d/programtoggle.sh alacritty msg create-window -T wttr.in -e sh -c 'curl https:##wttr.in/Istanbul; read'";
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
      @define-color activeColor   #5b9fcb;
      @define-color inactiveColor #3e6d8c;
      @define-color urgentColor   #FF0000;
      @define-color color00       #12100c;
      @define-color color01       #689ACF;
      @define-color color02       #5177A7;
      @define-color color03       #90AED4;
      @define-color color04       #0A73C7;
      @define-color color05       #B3B6B8;
      @define-color color06       #318CCB;
      @define-color color07       #c8d4e3;
      @define-color color08       #302a1f;
      @define-color color09       #72c7ff;
      @define-color color10       #5998e9;
      @define-color color11       #a4dfff;
      @define-color color12       #0196ff;
      @define-color color13       #d1f1ff;
      @define-color color14       #2fb8ff;
      @define-color color15       #eefdff;

      * {
      	border-radius: 5px;
      	font-family: Ubuntu Medium, FontAwesome5Brands, FontAwesome5Free, Arial, sans-serif;
      	font-size: 13px;
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
      	background-color: @inactiveColor;
      	color: @color15;
      	margin: 6px 0px 2px 0px;
      	padding: 0px 10px 0px 10px;
      }

      #workspaces button,
      #workspaces button label {
      	background-color: @inactiveColor;
      	color: @color15;
      	margin: 0px 0px 0px 0px;
      	padding: 0px 1px 0px 1px;
      }

      box.horizontal #tray widget window menu menuitem * {
      	background-color: transparent;
      }
    '';
  };
}
