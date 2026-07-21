{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.mtshell;
  osdPackage = pkgs.callPackage ../osd { osdConfig = cfg.osd; };
in
{
  options.programs.mtshell = {
    bar = {
      enable = lib.mkEnableOption "MTShell bar";

      base = {
        bg = lib.mkOption {
          type = lib.types.str;
          default = "#1e1e2e";
        };

        text = lib.mkOption {
          type = lib.types.str;
          default = "#cdd6f4";
        };

        active = lib.mkOption {
          type = lib.types.str;
          default = "#89b4fa";
        };

        inactive = lib.mkOption {
          type = lib.types.str;
          default = "#45475a";
        };

        urgent = lib.mkOption {
          type = lib.types.str;
          default = "#f38ba8";
        };

        border = lib.mkOption {
          type = lib.types.str;
          default = "#45475a";
        };

        fontName = lib.mkOption {
          type = lib.types.str;
          default = "Sans Serif";
        };

        fontSize = lib.mkOption {
          type = lib.types.int;
          default = 12;
        };

        iconTheme = lib.mkOption {
          type = lib.types.str;
          default = "Papirus-Dark";
        };

        iconThemePackage = lib.mkOption {
          type = lib.types.package;
          default = pkgs.papirus-icon-theme;
        };

        margin = lib.mkOption {
          type = lib.types.int;
          default = 2;
        };

        radius = lib.mkOption {
          type = lib.types.int;
          default = 5;
        };

        height = lib.mkOption {
          type = lib.types.int;
          default = 18;
        };

        padTop = lib.mkOption {
          type = lib.types.int;
          default = 2;
        };

        padBottom = lib.mkOption {
          type = lib.types.int;
          default = 3;
        };
      };

      position = lib.mkOption {
        type = lib.types.enum [
          "top"
          "bottom"
        ];
        default = "bottom";
      };

      height = lib.mkOption {
        type = lib.types.int;
        default = 27;
      };

      margin = lib.mkOption {
        type = lib.types.int;
        default = 3;
      };

      color = lib.mkOption {
        type = lib.types.str;
        default = "transparent";
      };

      opaque = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      separator = {
        defaultSize = lib.mkOption {
          type = lib.types.int;
          default = 3;
        };
      };

      workspaces = {
        iconFocused = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconActive = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconInactive = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        textFocused = lib.mkOption {
          type = lib.types.str;
          default = "#89b4fa";
        };

        textActive = lib.mkOption {
          type = lib.types.str;
          default = "#cdd6f4";
        };

        textInactive = lib.mkOption {
          type = lib.types.str;
          default = "#6c7086";
        };

        spacing = lib.mkOption {
          type = lib.types.int;
          default = 2;
        };
      };

      clock = {
        format = lib.mkOption {
          type = lib.types.str;
          default = "ddd dd MMM  HH:mm:ss";
        };

        interval = lib.mkOption {
          type = lib.types.int;
          default = 1000;
        };

        calendar = {
          enable = lib.mkEnableOption "calendar popup on clock hover";

          eventsCommand = lib.mkOption {
            type = lib.types.str;
            default = "";
          };

          openCommand = lib.mkOption {
            type = lib.types.str;
            default = "";
          };

          bg = lib.mkOption {
            type = lib.types.str;
            default = "#1e1e2e";
          };

          text = lib.mkOption {
            type = lib.types.str;
            default = "#cdd6f4";
          };

          border = lib.mkOption {
            type = lib.types.str;
            default = "#45475a";
          };

          active = lib.mkOption {
            type = lib.types.str;
            default = "#89b4fa";
          };

          subtext = lib.mkOption {
            type = lib.types.str;
            default = "#6c7086";
          };

          fontName = lib.mkOption {
            type = lib.types.str;
            default = "Sans Serif";
          };

          fontSize = lib.mkOption {
            type = lib.types.int;
            default = 14;
          };

          width = lib.mkOption {
            type = lib.types.int;
            default = 280;
          };

          height = lib.mkOption {
            type = lib.types.int;
            default = 260;
          };

          pad = lib.mkOption {
            type = lib.types.int;
            default = 10;
          };

          aboveBar = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
        };
      };

      mpd = {
        iconPlaying = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconPaused = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconStopped = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconConsume = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconRandom = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconRepeat = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconSingle = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        disconnectedText = lib.mkOption {
          type = lib.types.str;
          default = "MPD Off";
        };

        rightClickScript = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      weather = {
        location = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        interval = lib.mkOption {
          type = lib.types.int;
          default = 3600;
        };

        clickScript = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      systray = {
        compact = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        expandIcon = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      memory = {
        icon = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        interval = lib.mkOption {
          type = lib.types.int;
          default = 10;
        };

        onClick = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      idleInhibitor = {
        iconActivated = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconDeactivated = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      keyboardLayout = {
        onClick = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        format = lib.mkOption {
          type = lib.types.enum [
            "short"
            "long"
          ];
          default = "long";
        };
      };

      network = {
        iconWifi = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconEthernet = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconDisconnected = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        textDisconnected = lib.mkOption {
          type = lib.types.str;
          default = "Disconnected";
        };

        onClick = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      bluetooth = {
        iconConnected = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconDisconnected = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        onClick = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      pulseaudio = {
        icons = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            ""
            ""
            ""
          ];
        };

        iconMuted = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconMic = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconMicMuted = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        click = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        middleClick = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        rightClick = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        scrollUp = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        scrollDown = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      battery = {
        chargingIcon = lib.mkOption {
          type = lib.types.str;
          default = "󰚥";
        };

        chargingBackground = lib.mkOption {
          type = lib.types.str;
          default = "#5baa00";
        };

        criticalBackground = lib.mkOption {
          type = lib.types.str;
          default = "#bb0000";
        };

        device = lib.mkOption {
          type = lib.types.str;
          default = "BAT0";
        };

        icons = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        warning = lib.mkOption {
          type = lib.types.int;
          default = 30;
        };

        critical = lib.mkOption {
          type = lib.types.int;
          default = 1;
        };
      };

      backlight = {
        device = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        icons = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "󰃞"
            "󰃝"
            "󰃟"
            "󰃠"
            "󰃚"
          ];
        };

        scrollUp = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        scrollDown = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      powermenu = {
        icon = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconLock = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconLogout = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconSuspend = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconHibernate = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconShutdown = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconReboot = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        textLock = lib.mkOption {
          type = lib.types.str;
          default = "Lock";
        };

        textLogout = lib.mkOption {
          type = lib.types.str;
          default = "Logout";
        };

        textSuspend = lib.mkOption {
          type = lib.types.str;
          default = "Suspend";
        };

        textHibernate = lib.mkOption {
          type = lib.types.str;
          default = "Hibernate";
        };

        textShutdown = lib.mkOption {
          type = lib.types.str;
          default = "Shutdown";
        };

        textReboot = lib.mkOption {
          type = lib.types.str;
          default = "Reboot";
        };

        cmdLock = lib.mkOption {
          type = lib.types.str;
          default = "loginctl lock-session";
        };

        cmdLogout = lib.mkOption {
          type = lib.types.str;
          default = "loginctl terminate-user $USER";
        };

        cmdSuspend = lib.mkOption {
          type = lib.types.str;
          default = "systemctl suspend";
        };

        cmdHibernate = lib.mkOption {
          type = lib.types.str;
          default = "systemctl hibernate";
        };

        cmdShutdown = lib.mkOption {
          type = lib.types.str;
          default = "systemctl poweroff";
        };

        cmdReboot = lib.mkOption {
          type = lib.types.str;
          default = "systemctl reboot";
        };
      };

      notifier = {
        iconNotification = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconDnd = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };
    };

    notifier = {
      enable = lib.mkEnableOption "MTShell notifier";

      base = {
        bg = lib.mkOption {
          type = lib.types.str;
          default = "#1e1e2e";
        };

        text = lib.mkOption {
          type = lib.types.str;
          default = "#cdd6f4";
        };

        active = lib.mkOption {
          type = lib.types.str;
          default = "#89b4fa";
        };

        inactive = lib.mkOption {
          type = lib.types.str;
          default = "#45475a";
        };

        subtext = lib.mkOption {
          type = lib.types.str;
          default = "#a6adc8";
        };

        urgent = lib.mkOption {
          type = lib.types.str;
          default = "#f38ba8";
        };

        border = lib.mkOption {
          type = lib.types.str;
          default = "#45475a";
        };

        fontName = lib.mkOption {
          type = lib.types.str;
          default = "Sans Serif";
        };

        fontSize = lib.mkOption {
          type = lib.types.int;
          default = 12;
        };

        iconTheme = lib.mkOption {
          type = lib.types.str;
          default = "Papirus-Dark";
        };

        iconThemePackage = lib.mkOption {
          type = lib.types.package;
          default = pkgs.papirus-icon-theme;
        };
      };

      controlCenter = {
        width = lib.mkOption {
          type = lib.types.int;
          default = 500;
        };

        height = lib.mkOption {
          type = lib.types.int;
          default = 500;
        };

        marginTop = lib.mkOption {
          type = lib.types.int;
          default = 5;
        };

        marginBottom = lib.mkOption {
          type = lib.types.int;
          default = 5;
        };

        marginLeft = lib.mkOption {
          type = lib.types.int;
          default = 0;
        };

        marginRight = lib.mkOption {
          type = lib.types.int;
          default = 5;
        };

        positionX = lib.mkOption {
          type = lib.types.str;
          default = "right";
        };

        positionY = lib.mkOption {
          type = lib.types.str;
          default = "center";
        };
      };

      mpris = {
        iconPlay = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconPause = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconNext = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconPrevious = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconShuffle = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconShuffleActive = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconRepeat = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconRepeatActive = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        iconRepeatOne = lib.mkOption {
          type = lib.types.str;
          default = "";
        };

        imageDisplaySize = lib.mkOption {
          type = lib.types.int;
          default = 100;
        };
      };

      iconDnd = lib.mkOption {
        type = lib.types.str;
        default = "";
      };

      iconDndActive = lib.mkOption {
        type = lib.types.str;
        default = "";
      };

      popup = {
        width = lib.mkOption {
          type = lib.types.int;
          default = 350;
        };

        margin = lib.mkOption {
          type = lib.types.int;
          default = 8;
        };

        iconSize = lib.mkOption {
          type = lib.types.int;
          default = 32;
        };

        duration = lib.mkOption {
          type = lib.types.int;
          default = 5;
        };

        maxVisible = lib.mkOption {
          type = lib.types.int;
          default = 3;
        };
      };
    };

    osd = {
      enable = lib.mkEnableOption "MTShell OSD";

      bg = lib.mkOption {
        type = lib.types.str;
        default = "#1e1e2e";
      };

      text = lib.mkOption {
        type = lib.types.str;
        default = "#cdd6f4";
      };

      accent = lib.mkOption {
        type = lib.types.str;
        default = "#89b4fa";
      };

      border = lib.mkOption {
        type = lib.types.str;
        default = "#89b4fa";
      };

      fontName = lib.mkOption {
        type = lib.types.str;
        default = "Sans";
      };

      volumeIcons = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          ""
          ""
          ""
          ""
          ""
        ];
      };

      volumeMutedIcon = lib.mkOption {
        type = lib.types.str;
        default = "";
      };

      brightnessIcons = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "󰃞"
          "󰃝"
          "󰃟"
          "󰃠"
          "󰃚"
        ];
      };

      keyboardIcon = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.bar.enable || cfg.notifier.enable) (
      let
        notifierPackage = pkgs.callPackage ../notifier {
          iconThemePackage = cfg.notifier.base.iconThemePackage;
          notifierConfig = {
            base = {
              inherit (cfg.notifier.base)
                bg
                text
                active
                inactive
                subtext
                urgent
                border
                fontName
                fontSize
                iconTheme
                ;
            };
            controlCenter = {
              inherit (cfg.notifier.controlCenter)
                width
                height
                marginTop
                marginBottom
                marginLeft
                marginRight
                positionX
                positionY
                ;
            };
            mpris = {
              inherit (cfg.notifier.mpris)
                iconPlay
                iconPause
                iconNext
                iconPrevious
                iconShuffle
                iconShuffleActive
                iconRepeat
                iconRepeatActive
                iconRepeatOne
                imageDisplaySize
                ;
            };
            iconDnd = cfg.notifier.iconDnd or "";
            iconDndActive = cfg.notifier.iconDndActive or "";
            popup = {
              inherit (cfg.notifier.popup)
                width
                margin
                iconSize
                duration
                maxVisible
                ;
            };
          };
        };
        notifierShellPath = "${notifierPackage}/share/mtshell/notifier/shell.qml";
        barPackage = pkgs.callPackage ../bar {
          iconThemePackage = cfg.bar.base.iconThemePackage;
          barConfig = {
            osdIpc = lib.optionalString cfg.osd.enable "${pkgs.quickshell}/bin/qs -p ${osdPackage}/share/mtshell/osd/shell.qml ipc call -- osd show";
            inherit (cfg.bar)
              position
              height
              margin
              color
              opaque
              ;
            base = {
              inherit (cfg.bar.base)
                bg
                text
                active
                inactive
                urgent
                border
                fontName
                fontSize
                iconTheme
                margin
                radius
                height
                padTop
                padBottom
                ;
            };
            separator = {
              inherit (cfg.bar.separator) defaultSize;
            };
            workspaces = {
              inherit (cfg.bar.workspaces)
                iconFocused
                iconActive
                iconInactive
                textFocused
                textActive
                textInactive
                spacing
                ;
            };
            clock = {
              inherit (cfg.bar.clock) format interval;
              calendar = {
                inherit (cfg.bar.clock.calendar)
                  enable
                  eventsCommand
                  openCommand
                  bg
                  text
                  border
                  active
                  subtext
                  fontName
                  fontSize
                  width
                  height
                  pad
                  aboveBar
                  ;
              };
            };
            mpd = {
              inherit (cfg.bar.mpd)
                iconPlaying
                iconPaused
                iconStopped
                iconConsume
                iconRandom
                iconRepeat
                iconSingle
                disconnectedText
                rightClickScript
                ;
            };
            weather = {
              inherit (cfg.bar.weather)
                location
                interval
                clickScript
                ;
            };
            systray = {
              inherit (cfg.bar.systray)
                compact
                expandIcon
                ;
            };
            memory = {
              inherit (cfg.bar.memory)
                icon
                interval
                onClick
                ;
            };
            idleInhibitor = {
              inherit (cfg.bar.idleInhibitor)
                iconActivated
                iconDeactivated
                ;
            };
            keyboardLayout = {
              inherit (cfg.bar.keyboardLayout)
                onClick
                format
                ;
            };
            network = {
              inherit (cfg.bar.network)
                iconWifi
                iconEthernet
                iconDisconnected
                textDisconnected
                onClick
                ;
            };
            bluetooth = {
              inherit (cfg.bar.bluetooth)
                iconConnected
                iconDisconnected
                onClick
                ;
            };
            pulseaudio = {
              inherit (cfg.bar.pulseaudio)
                icons
                iconMuted
                iconMic
                iconMicMuted
                click
                middleClick
                rightClick
                scrollUp
                scrollDown
                ;
            };
            battery = {
              inherit (cfg.bar.battery)
                device
                icons
                warning
                critical
                ;
            };
            backlight = {
              inherit (cfg.bar.backlight)
                device
                icons
                scrollUp
                scrollDown
                ;
            };
            powermenu = {
              inherit (cfg.bar.powermenu)
                icon
                iconLock
                iconLogout
                iconSuspend
                iconHibernate
                iconShutdown
                iconReboot
                textLock
                textLogout
                textSuspend
                textHibernate
                textShutdown
                textReboot
                cmdLock
                cmdLogout
                cmdSuspend
                cmdHibernate
                cmdShutdown
                cmdReboot
                ;
            };
            notifier = {
              inherit (cfg.bar.notifier)
                iconNotification
                iconDnd
                ;
            };
            quickshell-bin = "${pkgs.quickshell}/bin/qs";
            notifier-shell-path = notifierShellPath;
          };
        };
      in
      {
        home.packages = [ barPackage ] ++ lib.optional cfg.notifier.enable notifierPackage;

        services.swaync.enable = lib.mkForce false;
        services.mako.enable = lib.mkForce false;

        systemd.user.services.mtshell-bar = lib.mkIf cfg.bar.enable {
          Unit = {
            Description = "MTShell bar";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
            StartLimitIntervalSec = "30s";
            StartLimitBurst = 3;
          };
          Service = {
            ExecStart = "${lib.getExe' pkgs.util-linux "flock"} --nonblock %t/mtshell-bar.lock ${barPackage}/bin/mtshell-bar";
            Restart = "on-failure";
            RestartSec = "5s";
            RestartPreventExitStatus = 255;
            KillMode = "control-group";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };

        systemd.user.services.mtshell-notifier = lib.mkIf cfg.notifier.enable {
          Unit = {
            Description = "MTShell notifier";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${notifierPackage}/bin/mtshell-notifier";
            Restart = "on-failure";
            RestartSec = "3s";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      }
    ))
    (lib.mkIf cfg.osd.enable {
      home.packages = [ osdPackage ];
      xdg.configFile."mtshell/osd" = {
        source = "${osdPackage}/share/mtshell/osd";
        recursive = true;
      };
      systemd.user.services.mtshell-osd = {
        Unit = {
          Description = "MTShell OSD";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${osdPackage}/bin/mtshell-osd";
          Restart = "on-failure";
          RestartSec = "3s";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    })
  ];
}
