{
  lib,
  pkgs,
  quickshell ? pkgs.quickshell,
  iconThemePackage ? pkgs.papirus-icon-theme,
  barConfig ? { },
  ...
}:

let
  cfg = barConfig;
  osd-ipc = cfg.osdIpc or "";

  calendarPython = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);
  calendar-events = pkgs.writeShellApplication {
    name = "mtshell-calendar-events";
    runtimeInputs = [
      calendarPython
      pkgs.evolution-data-server
      pkgs.libical
      pkgs.libxml2
      pkgs.libsoup_3
      pkgs.gobject-introspection
      pkgs.json-glib
    ];
    text = ''
      export GI_TYPELIB_PATH="${pkgs.evolution-data-server}/lib/girepository-1.0:${pkgs.libical}/lib/girepository-1.0:${pkgs.libxml2}/lib/girepository-1.0:${pkgs.libsoup_3}/lib/girepository-1.0:${pkgs.gobject-introspection}/lib/girepository-1.0:${pkgs.json-glib}/lib/girepository-1.0''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"
      exec ${calendarPython}/bin/python - "$@" <<'PYTHON'
      import json
      import sys
      from datetime import date, datetime, timedelta

      import gi

      gi.require_version("ECal", "2.0")
      gi.require_version("EDataServer", "1.2")
      from gi.repository import ECal, EDataServer

      start = date.fromisoformat(sys.argv[1])
      end = date.fromisoformat(sys.argv[2])
      calendar_filter = sys.argv[3] if len(sys.argv) > 3 else ""
      start_time = datetime.combine(start - timedelta(days=1), datetime.min.time())
      end_time = datetime.combine(end + timedelta(days=1), datetime.min.time())
      sexp = ('(occur-in-time-range? (make-time "{}") (make-time "{}") "UTC")'
              .format(start_time.strftime("%Y%m%dT%H%M%SZ"), end_time.strftime("%Y%m%dT%H%M%SZ")))

      registry = EDataServer.SourceRegistry.new_sync(None)
      days = set()
      calendars = []
      sources = registry.list_sources(EDataServer.SOURCE_EXTENSION_CALENDAR)
      for source in sources:
          uid = source.get_uid() or ""
          name = source.get_display_name() or uid or "Calendar"
          calendars.append({"uid": uid, "name": name})
          if calendar_filter and calendar_filter not in (uid, name):
              continue
          client = ECal.Client.connect_sync(source, ECal.ClientSourceType.EVENTS, 1, None)
          if client is None:
              continue
          success, components = client.get_object_list_as_comps_sync(sexp, None)
          if not success:
              continue
          for component in components:
              dtstart = component.get_dtstart()
              if dtstart is None or dtstart.get_value() is None:
                  continue
              event_day = dtstart.get_value().get_date()
              if event_day is not None:
                  days.add("{:04d}-{:02d}-{:02d}".format(event_day[0], event_day[1], event_day[2]))

      print(json.dumps({"days": sorted(days), "calendars": calendars}))
      PYTHON
    '';
  };

  base = cfg.base or { };
  base-bg = base.bg or "#1e1e2e";
  base-text = base.text or "#cdd6f4";
  base-active = base.active or "#89b4fa";
  base-inactive = base.inactive or "#45475a";
  base-urgent = base.urgent or "#f38ba8";
  base-border = base.border or "#45475a";
  base-font-name = base.fontName or "Sans Serif";
  base-font-size = base.fontSize or 12;
  base-icon-theme = base.iconTheme or "Papirus-Dark";
  base-margin = base.margin or 2;
  base-radius = base.radius or 5;
  base-height = base.height or 18;
  base-pad-top = base.padTop or 2;
  base-pad-bottom = base.padBottom or 3;

  position = cfg.position or "bottom";
  height = cfg.height or 27;
  margin = cfg.margin or 3;
  bar-color = cfg.color or "transparent";
  bar-opaque = if (cfg.opaque or false) then "true" else "false";

  ws = cfg.workspaces or { };
  ws-icon-focused = ws.iconFocused or "";
  ws-icon-active = ws.iconActive or "";
  ws-icon-inactive = ws.iconInactive or "";
  ws-text-focused = ws.textFocused or "#89b4fa";
  ws-text-active = ws.textActive or "#cdd6f4";
  ws-text-inactive = ws.textInactive or "#6c7086";
  ws-spacing = ws.spacing or 2;

  sep = cfg.separator or { };
  separator-default-size = sep.defaultSize or 3;

  cl = cfg.clock or { };
  clock-format = cl.format or "ddd dd MMM  HH:mm:ss";
  clock-interval = cl.interval or 1000;

  cal = cl.calendar or { };
  calendar-enabled = if (cal.enable or false) then "true" else "false";
  calendar-events-command =
    if (cal.eventsCommand or "") != "" then cal.eventsCommand else lib.getExe calendar-events;
  calendar-open-command = cal.openCommand or "";
  calendar-bg = cal.bg or base-bg;
  calendar-text = cal.text or base-text;
  calendar-border = cal.border or base-border;
  calendar-active = cal.active or base-active;
  calendar-subtext = cal.subtext or base-inactive;
  calendar-font-name = cal.fontName or base-font-name;
  calendar-font-size = cal.fontSize or (base-font-size + 2);
  calendar-width = cal.width or 280;
  calendar-height = cal.height or 260;
  calendar-pad = cal.pad or 10;
  calendar-above-bar = if (cal.aboveBar or true) then "true" else "false";

  mpd = cfg.mpd or { };
  mpc-bin = "${pkgs.mpc}/bin/mpc";
  mpd-icon-playing = mpd.iconPlaying or "";
  mpd-icon-paused = mpd.iconPaused or "";
  mpd-icon-stopped = mpd.iconStopped or "";
  mpd-icon-consume = mpd.iconConsume or "";
  mpd-icon-random = mpd.iconRandom or "";
  mpd-icon-repeat = mpd.iconRepeat or "";
  mpd-icon-single = mpd.iconSingle or "";
  mpd-disconnected-text = mpd.disconnectedText or "MPD Off";
  mpd-right-click-script = mpd.rightClickScript or "";

  we = cfg.weather or { };
  weather-location = we.location or "";
  weather-interval = we.interval or 3600;
  weather-click-script = we.clickScript or "";
  weather-cmd = "${pkgs.curl}/bin/curl -s 'https://wttr.in/${weather-location}?format=1' | ${pkgs.gnused}/bin/sed 's/ //1'";

  st = cfg.systray or { };
  systray-compact = if (st.compact or false) then "true" else "false";
  systray-expand-icon = st.expandIcon or "";

  me = cfg.memory or { };
  memory-icon = me.icon or "";
  memory-interval = me.interval or 10;
  memory-on-click = me.onClick or "";

  ii = cfg.idleInhibitor or { };
  idle-icon-activated = ii.iconActivated or "";
  idle-icon-deactivated = ii.iconDeactivated or "";

  kl = cfg.keyboardLayout or { };
  keyboard-on-click = kl.onClick or "";
  keyboard-format = kl.format or "long";

  nw = cfg.network or { };
  network-icon-wifi = nw.iconWifi or "";
  network-icon-ethernet = nw.iconEthernet or "";
  network-icon-disconnected = nw.iconDisconnected or "";
  network-text-disconnected = nw.textDisconnected or "Disconnected";
  network-on-click = nw.onClick or "";

  bt = cfg.bluetooth or { };
  bluetooth-icon-connected = bt.iconConnected or "";
  bluetooth-icon-disconnected = bt.iconDisconnected or "";
  bluetooth-on-click = bt.onClick or "";

  pa = cfg.pulseaudio or { };
  pulseaudio-icons =
    pa.icons or [
      ""
      ""
      ""
    ];
  pulseaudio-icon-volume-0 = builtins.elemAt pulseaudio-icons 0;
  pulseaudio-icon-volume-1 = builtins.elemAt pulseaudio-icons 1;
  pulseaudio-icon-volume-2 = builtins.elemAt pulseaudio-icons 2;
  pulseaudio-icon-muted = pa.iconMuted or "";
  pulseaudio-icon-mic = pa.iconMic or "";
  pulseaudio-icon-mic-muted = pa.iconMicMuted or "";
  pulseaudio-click-cmd = pa.click or "";
  pulseaudio-middle-click-cmd = pa.middleClick or "";
  pulseaudio-right-click-cmd = pa.rightClick or "";
  pulseaudio-scroll-up-cmd = pa.scrollUp or "";
  pulseaudio-scroll-down-cmd = pa.scrollDown or "";
  wpctl-bin = "${pkgs.wireplumber}/bin/wpctl";
  inotifywait-bin = "${pkgs.inotify-tools}/bin/inotifywait";
  upower-bin = "${pkgs.upower}/bin/upower";
  swaymsg-bin = "${pkgs.sway}/bin/swaymsg";
  pactl-bin = "${pkgs.pulseaudio}/bin/pactl";

  bat = cfg.battery or { };
  battery-device = bat.device or "";
  battery-charging-icon = bat.chargingIcon or "󰚥";
  battery-charging-background = bat.chargingBackground or "#365314";
  battery-critical-background = bat.criticalBackground or "#7f1d1d";
  battery-icons =
    bat.icons or [
      ""
      ""
      ""
      ""
      ""
    ];
  battery-icon-0 = builtins.elemAt battery-icons 0;
  battery-icon-1 = builtins.elemAt battery-icons 1;
  battery-icon-2 = builtins.elemAt battery-icons 2;
  battery-icon-3 = builtins.elemAt battery-icons 3;
  battery-icon-4 = builtins.elemAt battery-icons 4;
  battery-warning = bat.warning or 30;
  battery-critical = bat.critical or 1;

  bl = cfg.backlight or { };
  backlight-device = bl.device or "";
  backlight-icons =
    bl.icons or [
      "󰃞"
      "󰃝"
      "󰃟"
      "󰃠"
      "󰃚"
    ];
  backlight-icon-0 = builtins.elemAt backlight-icons 0;
  backlight-icon-1 = builtins.elemAt backlight-icons 1;
  backlight-icon-2 = builtins.elemAt backlight-icons 2;
  backlight-icon-3 = builtins.elemAt backlight-icons 3;
  backlight-icon-4 = builtins.elemAt backlight-icons 4;
  backlight-scroll-up-cmd = bl.scrollUp or "";
  backlight-scroll-down-cmd = bl.scrollDown or "";

  pm = cfg.powermenu or { };
  powermenu-icon = pm.icon or "";
  powermenu-icon-lock = pm.iconLock or "";
  powermenu-icon-logout = pm.iconLogout or "";
  powermenu-icon-suspend = pm.iconSuspend or "";
  powermenu-icon-hibernate = pm.iconHibernate or "";
  powermenu-icon-shutdown = pm.iconShutdown or "";
  powermenu-icon-reboot = pm.iconReboot or "";
  powermenu-text-lock = pm.textLock or "Lock";
  powermenu-text-logout = pm.textLogout or "Logout";
  powermenu-text-suspend = pm.textSuspend or "Suspend";
  powermenu-text-hibernate = pm.textHibernate or "Hibernate";
  powermenu-text-shutdown = pm.textShutdown or "Shutdown";
  powermenu-text-reboot = pm.textReboot or "Reboot";
  powermenu-cmd-lock = pm.cmdLock or "loginctl lock-session";
  powermenu-cmd-logout = pm.cmdLogout or "loginctl terminate-user $USER";
  powermenu-cmd-suspend = pm.cmdSuspend or "systemctl suspend";
  powermenu-cmd-hibernate = pm.cmdHibernate or "systemctl hibernate";
  powermenu-cmd-shutdown = pm.cmdShutdown or "systemctl poweroff";
  powermenu-cmd-reboot = pm.cmdReboot or "systemctl reboot";

  nt = cfg.notifier or { };
  notifier-icon-notification = nt.iconNotification or "";
  notifier-icon-dnd = nt.iconDnd or "";
  quickshell-bin = cfg.quickshell-bin or "${pkgs.quickshell}/bin/qs";
  notifier-shell-path = cfg.notifier-shell-path or "";

  subs = {
    inherit
      base-bg
      base-text
      base-active
      base-inactive
      base-urgent
      base-border
      base-font-name
      base-font-size
      base-icon-theme
      base-margin
      base-radius
      base-height
      base-pad-top
      base-pad-bottom
      position
      height
      margin
      bar-color
      bar-opaque
      ws-icon-focused
      ws-icon-active
      ws-icon-inactive
      ws-text-focused
      ws-text-active
      ws-text-inactive
      ws-spacing
      separator-default-size
      clock-format
      clock-interval
      calendar-enabled
      calendar-events-command
      calendar-open-command
      calendar-bg
      calendar-text
      calendar-border
      calendar-active
      calendar-subtext
      calendar-font-name
      calendar-font-size
      calendar-width
      calendar-height
      calendar-pad
      calendar-above-bar
      mpc-bin
      mpd-icon-playing
      mpd-icon-paused
      mpd-icon-stopped
      mpd-icon-consume
      mpd-icon-random
      mpd-icon-repeat
      mpd-icon-single
      mpd-disconnected-text
      mpd-right-click-script
      weather-location
      weather-interval
      weather-click-script
      weather-cmd
      systray-compact
      systray-expand-icon
      memory-icon
      memory-interval
      memory-on-click
      idle-icon-activated
      idle-icon-deactivated
      keyboard-on-click
      keyboard-format
      network-icon-wifi
      network-icon-ethernet
      network-icon-disconnected
      network-text-disconnected
      network-on-click
      bluetooth-icon-connected
      bluetooth-icon-disconnected
      bluetooth-on-click
      pulseaudio-icon-volume-0
      pulseaudio-icon-volume-1
      pulseaudio-icon-volume-2
      pulseaudio-icon-muted
      pulseaudio-icon-mic
      pulseaudio-icon-mic-muted
      pulseaudio-click-cmd
      pulseaudio-middle-click-cmd
      pulseaudio-right-click-cmd
      pulseaudio-scroll-up-cmd
      pulseaudio-scroll-down-cmd
      pactl-bin
      wpctl-bin
      inotifywait-bin
      upower-bin
      osd-ipc
      swaymsg-bin
      battery-device
      battery-charging-icon
      battery-charging-background
      battery-critical-background
      battery-icon-0
      battery-icon-1
      battery-icon-2
      battery-icon-3
      battery-icon-4
      battery-warning
      battery-critical
      backlight-device
      backlight-icon-0
      backlight-icon-1
      backlight-icon-2
      backlight-icon-3
      backlight-icon-4
      backlight-scroll-up-cmd
      backlight-scroll-down-cmd
      powermenu-icon
      powermenu-icon-lock
      powermenu-icon-logout
      powermenu-icon-suspend
      powermenu-icon-hibernate
      powermenu-icon-shutdown
      powermenu-icon-reboot
      powermenu-text-lock
      powermenu-text-logout
      powermenu-text-suspend
      powermenu-text-hibernate
      powermenu-text-shutdown
      powermenu-text-reboot
      powermenu-cmd-lock
      powermenu-cmd-logout
      powermenu-cmd-suspend
      powermenu-cmd-hibernate
      powermenu-cmd-shutdown
      powermenu-cmd-reboot
      notifier-icon-notification
      notifier-icon-dnd
      quickshell-bin
      notifier-shell-path
      ;
  };

  substituteQml =
    src:
    pkgs.substitute {
      inherit src;
      substitutions = lib.flatten (
        lib.mapAttrsToList (k: v: [
          "--replace"
          "@${k}@"
          (toString v)
        ]) subs
      );
    };

  qmlSrc = ./qml;
  qmlFiles =
    builtins.concatMap
      (
        dir:
        let
          basePath = if dir == "root" then qmlSrc else "${qmlSrc}/${dir}";
          entries = builtins.readDir basePath;
        in
        lib.mapAttrsToList
          (name: _: {
            inherit name;
            src = "${basePath}/${name}";
            dest = if dir == "root" then name else "${dir}/${name}";
          })
          (
            lib.filterAttrs (
              n: t: t == "regular" && (lib.hasSuffix ".qml" n || lib.hasSuffix ".js" n || n == "qmldir")
            ) entries
          )
      )
      [
        "root"
        "widgets"
      ];

  qmlDir = pkgs.runCommandLocal "mtshell-bar-qml" { } ''
    mkdir -p $out/widgets
    ${lib.concatStringsSep "\n" (
      map (f: ''
        cp ${substituteQml f.src} $out/${f.dest}
      '') qmlFiles
    )}
  '';

  iconThemeConf = pkgs.runCommand "mtshell-icon-theme-conf" { } ''
    mkdir -p $out/icons/default
    cat >$out/icons/default/index.theme <<THEME
    [Icon Theme]
    Inherits=${base-icon-theme}
    THEME
  '';
in
with pkgs;
stdenv.mkDerivation {
  pname = "mtshell-bar";
  version = "0.1.0";

  src = qmlDir;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mtshell/bar
    cp -r "$src"/. $out/share/mtshell/bar/

    mkdir -p $out/bin
    cat >$out/bin/mtshell-bar <<'SCRIPT'
    #!${runtimeShell}
    export XDG_DATA_DIRS="${iconThemeConf}:${iconThemePackage}/share:$XDG_DATA_DIRS"
    export XDG_CURRENT_DESKTOP="KDE"
    exec ${lib.getExe quickshell} -p ${placeholder "out"}/share/mtshell/bar/shell.qml "$@"
    SCRIPT
    chmod +x $out/bin/mtshell-bar

    runHook postInstall
  '';

  passthru.templatesPath = "${placeholder "out"}/share/mtshell/bar";

  meta = {
    description = "MTShell Bar";
    mainProgram = "mtshell-bar";
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
  };
}
