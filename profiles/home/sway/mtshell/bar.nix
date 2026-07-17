{
  config,
  lib,
  pkgs,
  ...
}:

with config.stylix.customColors.withHashtag;

let
  curl = lib.getExe pkgs.curl;
  btop = lib.getExe pkgs.btop;
  swaymsg = lib.getExe' pkgs.sway "swaymsg";
  nmeditor = lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor";
  blueman = lib.getExe pkgs.blueman;
  programToggler = "${home}/.local/bin/program-toggler";
  wpctl = lib.getExe' pkgs.wireplumber "wpctl";
  pavucontrol = lib.getExe pkgs.pavucontrol;
  brightnessctl = lib.getExe pkgs.brightnessctl;
  home = config.home.homeDirectory;
  powermenu = "${home}/.local/bin/powermenu";
  term =
    title: command:
    (
      if config.preferences.terminal == "alacritty" then
        lib.getExe pkgs.alacritty + " -T " + title + " -e " + command
      else if config.preferences.terminal == "foot" then
        (lib.getExe' pkgs.foot "footclient") + " -T ${title} ${command}"
      else
        throw "Unsupported terminal: ${config.preferences.terminal}"
    );
in
{
  config = lib.mkIf (lib.hasSuffix "linux" pkgs.stdenv.hostPlatform.system) {
    preferences.bar = lib.mkDefault "mtshell";
    programs.mtshell = {
      bar = {
        enable = lib.mkIf (config.preferences.bar == "mtshell") true;
        position = "top";
        height = 27;
        margin = 3;
        color = "transparent";
        opaque = false;
        base = {
          bg = background;
          inherit
            text
            active
            inactive
            urgent
            border
            ;
          fontName = config.stylix.fonts.sansSerif.name;
          fontSize = config.stylix.fonts.sizes.applications + 2;
          iconTheme = config.iconthemecfg.dark;
          iconThemePackage = config.iconthemecfg.package;
          margin = 7;
          radius = 5;
          height = 21;
          padTop = 6;
          padBottom = 0;
        };
        workspaces = {
          iconFocused = "";
          iconActive = "";
          iconInactive = "";
          textFocused = text;
          textActive = text;
          textInactive = text;
          spacing = 4;
        };
        clock = {
          format = "ddd dd MMM  HH:mm:ss";
          interval = 1000;
          calendar = {
            enable = true;
            openCommand = "${lib.getExe pkgs.evolution} calendar:///?startdate=$(printf %s $1 | tr -d -)$(printf %s '&')enddate=$(printf %s $1 | tr -d -)";
            bg = background;
            inherit
              text
              active
              border
              ;
            subtext = "#6c7086";
            fontName = config.stylix.fonts.sansSerif.name;
            fontSize = config.stylix.fonts.sizes.applications + 2;
            width = 280;
            height = 260;
            pad = 10;
            aboveBar = false;
          };
        };
        mpd = {
          iconPlaying = "";
          iconPaused = "";
          iconStopped = "";
          iconConsume = " ";
          iconRandom = " ";
          iconRepeat = "";
          iconSingle = "1 ";
          disconnectedText = "MPD Off ";
          rightClickScript = "${config.home.homeDirectory}/.config/${config.preferences.desktopenv}/scripts.d/media.sh";
        };
        weather = {
          location = config.preferences.weatherLocation;
          interval = 3600;
          clickScript = "${config.home.homeDirectory}/.local/bin/program-toggler ${term "wttr.in" "sh -c '${curl} https://wttr.in/${config.preferences.weatherLocation}; read'"}";
        };
        systray = {
          compact = true;
          expandIcon = "";
        };
        memory = {
          icon = "";
          interval = 10;
          onClick = "${config.home.homeDirectory}/.local/bin/program-toggler ${term "BTOP" btop}";
        };
        idleInhibitor = {
          iconActivated = "";
          iconDeactivated = "";
        };
        keyboardLayout = {
          onClick = ''${swaymsg} input "type:keyboard" xkb_switch_layout next'';
          format = "short";
        };
        network = {
          iconWifi = "";
          iconEthernet = "";
          iconDisconnected = "⚠";
          textDisconnected = "Disconnected";
          onClick = "${config.home.homeDirectory}/.local/bin/program-toggler ${nmeditor}";
        };
        bluetooth = {
          iconConnected = "";
          iconDisconnected = "";
          onClick = "${programToggler} ${blueman}";
        };
        pulseaudio = {
          icons = [
            " "
            " "
            " "
          ];
          iconMuted = "󰝟";
          iconMic = "";
          iconMicMuted = "";
          click = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
          middleClick = "${home}/.local/bin/program-toggler ${pavucontrol}";
          rightClick = "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          scrollUp = "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          scrollDown = "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        };
        battery = {
          chargingIcon = "󰚥";
          chargingBackground = "#5baa00";
          criticalBackground = "#bb0000";
          icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          warning = 30;
          critical = 20;
        };
        backlight = {
          icons = [
            "󰃞"
            "󰃝"
            "󰃟"
            "󰃠"
            "󰃚"
          ];
          scrollUp = "${brightnessctl} set +5%";
          scrollDown = "${brightnessctl} set 5%-";
        };
        powermenu = {
          icon = "";
          iconLock = "";
          iconLogout = "";
          iconSuspend = "";
          iconHibernate = "";
          iconShutdown = "";
          iconReboot = "";
          textLock = "Lock";
          textLogout = "Logout";
          textSuspend = "Suspend";
          textHibernate = "Hibernate";
          textShutdown = "Shutdown";
          textReboot = "Reboot";
          cmdLock = "${powermenu} --lock";
          cmdLogout = "rm $XDG_RUNTIME_DIR/.autostart; loginctl terminate-user $USER";
          cmdSuspend = "${powermenu} --suspend";
          cmdHibernate = "${powermenu} --lock; systemctl hibernate";
          cmdShutdown = "systemctl poweroff";
          cmdReboot = "systemctl reboot -i";
        };
        notifier = {
          iconNotification = "";
          iconDnd = "";
        };
      };
    };
  };
}
