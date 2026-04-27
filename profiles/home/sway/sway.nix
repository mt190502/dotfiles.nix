{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
  modifier = "Mod4";
  lock =
    if config.preferences.lock-app == "swaylock" then
      "${home}/.config/sway/scripts.d/blurlock"
    else
      config.preferences.lock-app;
  menu =
    if config.preferences.menu == "wofi" then
      "${wofi} --prompt 'Search Apps' --show drun"
    else if config.preferences.menu == "vicinae" then
      "${vicinae}"
    else
      throw "No preferred menu selected";
  term =
    command:
    (
      if config.preferences.terminal == "alacritty" then
        lib.getExe pkgs.alacritty + " -e " + command
      else if config.preferences.terminal == "foot" then
        (lib.getExe' pkgs.foot "footclient") + " ${command}"
      else
        throw "Unsupported terminal: ${config.preferences.terminal}"
    );
  termid =
    if config.preferences.terminal == "alacritty" then
      "Alacritty"
    else if config.preferences.terminal == "foot" then
      "foot"
    else
      throw "Unsupported terminal: ${config.preferences.terminal}";
  inherit (config.bin)
    brightnessctl
    cliphist
    dolphin
    flatpak
    mpv
    pactl
    playerctl
    swayidle
    swaymsg
    tmux
    vicinae
    wl-copy
    wlsunset
    wofi
    ;
in
{
  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false;
    systemd = {
      enable = true;
      variables = [
        "DISPLAY"
        "GNOME_KEYRING_CONTROL"
        "LD_LIBRARY_PATH"
        "NIXOS_OZONE_WL"
        "PATH"
        "SSH_AUTH_SOCK"
        "SWAYSOCK"
        "WAYLAND_DISPLAY"
        "XAUTHORITY"
        "XCURSOR_SIZE"
        "XCURSOR_THEME"
        "XDG_CURRENT_DESKTOP"
        "XDG_DATA_DIRS"
        "XDG_SESSION_TYPE"
      ];
      xdgAutostart = true;
    };
    config = {
      inherit modifier menu;
      terminal = config.preferences.terminal;

      ##############################
      #
      ## Colors and Fonts
      #
      ##############################
      fonts = {
        names = [
          config.stylix.fonts.sansSerif.name
          "pango"
        ];
        size = config.stylix.fonts.sizes.applications + 0.0;
      };
      colors = with config.stylix.customColors.withHashtag; {
        inherit background;
        focused = {
          background = active;
          border = active;
          text = background;
          indicator = active;
          childBorder = active;
        };
        focusedInactive = {
          inherit text;
          background = inactive;
          border = inactive;
          indicator = inactive;
          childBorder = inactive;
        };
        unfocused = {
          inherit background text;
          border = background;
          indicator = background;
          childBorder = background;
        };
        urgent = {
          background = urgent;
          border = urgent;
          text = background;
          indicator = urgent;
          childBorder = urgent;
        };
      };

      ##############################
      #
      ## Inputs
      #
      ##############################
      input = {
        "type:keyboard" = {
          xkb_layout = "us,tr";
          xkb_numlock = "enabled";
          xkb_options = "grp:win_space_toggle";
        };
        "type:touchpad" = {
          dwt = "enabled";
          tap = "enabled";
          natural_scroll = "enabled";
          middle_emulation = "enabled";
        };
      };

      ##############################
      #
      ## Outputs
      #
      ##############################
      output = {
        "*" = {
          adaptive_sync = "on";
          subpixel = "rgb";
        };
      };

      ##############################
      #
      ## Settings
      #
      ##############################
      bars = [
        {
          command = "true";
          position = "top";
          workspaceButtons = true;
        }
      ];
      floating.border = 5;
      floating.modifier = modifier;
      focus.newWindow = "focus";
      gaps = {
        inner = 5;
        outer = 0;
      };
      window.border = 0;
      workspaceLayout = "tabbed";

      ##############################
      #
      ## Shortcuts
      #
      ##############################
      modes = {
        apptray = {
          "q" = "exec $browser    ; mode 'default'";
          "s" = "exec $filemanager; mode 'default'";
          "x" = "exec $media      ; mode 'default'";
          "Return" = "mode 'default'";
          "Escape" = "mode 'default'";
          "${modifier}+Tab" = "mode 'default'";
        };
        resize = {
          "Right" = "resize shrink width  10 px or 10 ppt";
          "Up" = "resize grow   height 10 px or 10 ppt";
          "Down" = "resize shrink height 10 px or 10 ppt";
          "Left" = "resize grow   width  10 px or 10 ppt";
          "Return" = "mode 'default'";
          "Escape" = "mode 'default'";
          "${modifier}+r" = "mode 'default'";
        };
        screenshot = {
          "${modifier}+shift+s" = "exec ${home}/.config/sway/scripts.d/grimshot -r; mode 'default'";
          "a" = " exec ${home}/.config/sway/scripts.d/grimshot -a; mode 'default'";
          "f" = " exec ${home}/.config/sway/scripts.d/grimshot -f; mode 'default'";
          "Return" = "mode 'default'";
          "Escape" = "mode 'default'";
        };
      };
      keybindings = {
        #~~~ modes
        "${modifier}+r" = "mode 'resize'";
        "${modifier}+shift+s" = "mode 'screenshot'";
        "${modifier}+Tab" = "mode 'apptray'";

        #~~~ focus
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";

        #~~~ movement
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";

        #~~~ window
        "${modifier}+f" = "fullscreen";
        "${modifier}+Shift+space" =
          "exec ${swaymsg} input 'type:keyboard' xkb_switch_layout next && ${swaymsg} floating toggle"; #~ https://github.com/swaywm/sway/issues/8403
        "${modifier}+shift+1" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 1";
        "${modifier}+shift+2" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 2";
        "${modifier}+shift+3" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 3";
        "${modifier}+shift+4" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 4";
        "${modifier}+$altMod+shift+1" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 5";
        "${modifier}+$altMod+shift+2" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 6";
        "${modifier}+$altMod+shift+3" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 7";
        "${modifier}+$altMod+shift+4" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 8";

        #~~~ workspace
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+1" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 1";
        "${modifier}+2" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 2";
        "${modifier}+3" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 3";
        "${modifier}+4" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 4";
        "${modifier}+$altMod+1" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 5";
        "${modifier}+$altMod+2" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 6";
        "${modifier}+$altMod+3" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 7";
        "${modifier}+$altMod+4" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 8";

        #~~~ sound
        "XF86AudioRaiseVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec ${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle";

        #~~~ brightness (for Laptops)
        "XF86MonBrightnessUp" = "exec ${brightnessctl} set +5%";
        "XF86MonBrightnessDown" = "exec ${brightnessctl} set 5%-";

        #~~~ playerctl
        "XF86AudioPlay" = "exec ${playerctl} play-pause";
        "XF86AudioPause" = "exec ${playerctl} play-pause";
        "XF86AudioNext" = "exec ${playerctl} next";
        "XF86AudioPrev" = "exec ${playerctl} previous";
        "$altMod+Left" = "exec ${playerctl} previous";
        "$altMod+Right" = "exec ${playerctl} next";

        #~~~ sway
        "${modifier}+Shift+r" = "reload";
        "${modifier}+q" = "kill";

        #~~~ other
        "${modifier}+Return" = "exec ${term "bash -c \"${tmux} attach -t daemonmodetmux\""}";
        "${modifier}+l" = "exec ${lock}";
        "ctrl+period" = "exec ${home}/.config/sway/scripts.d/dropdown.sh";
      }
      // (
        if config.preferences.menu == "wofi" then
          {
            #~~~ clipboard (wofi)
            "${modifier}+v" = "exec ${cliphist} list | ${wofi} --show dmenu | ${cliphist} decode | ${wl-copy}";
            "${modifier}+shift+v" = "exec ${cliphist} wipe";

            #~~~ others
            "${modifier}+d" = "exec ${home}/.local/bin/program-toggler ${menu}";
            "${modifier}+period" = "exec ${home}/.local/bin/program-toggler ${home}/.local/bin/wofimoji";
            "${modifier}+shift+d" =
              "exec ${home}/.local/bin/program-toggler ${home}/.local/bin/easy-tesseract -e";
            "${modifier}+shift+f" =
              "exec ${home}/.local/bin/program-toggler ${home}/.local/bin/easy-tesseract -t";
          }
        else if config.preferences.menu == "vicinae" then
          {
            #~~~ clipboard (vicinae)
            "${modifier}+v" = "exec ${menu} 'vicinae://extensions/vicinae/clipboard/history'";

            #~~~ others
            "${modifier}+d" = "exec ${menu} toggle";
          }
        else
          { }
      );

      ##############################
      #
      ## Window Rules
      #
      ##############################
      floating.criteria = [
        {
          app_id = "(firefox|LibreWolf)";
          title = "^(.*)Sharing Indicator(.*)";
        }
        {
          app_id = "(firefox|LibreWolf)";
          title = "^Extension:(.*)";
        }
        {
          app_id = "(firefox|LibreWolf)";
          title = "^Library$";
        }
        {
          app_id = "(firefox|LibreWolf)";
          title = "^Picture-in-Picture(.*)$";
        }
        { app_id = "1Password"; }
        {
          app_id = termid;
          title = config.preferences.mediaplayer;
        }
        {
          app_id = termid;
          title = "nmtui";
        }
        {
          app_id = termid;
          title = "wttr.in";
        }
        { app_id = "com.nextcloud.desktopclient.nextcloud"; }
        { app_id = "com.usebottles.bottles"; }
        { app_id = "evolution-alarm-notify"; }
        {
          app_id = "flameshot";
          title = "flameshot";
        }
        { app_id = "nm-connection-editor$"; }
        { app_id = "org.freedesktop.impl.portal.desktop.kde"; }
        { app_id = "org.gnome.Calculator"; }
        { app_id = "org.kde.discover"; }
        { app_id = "org.kde.dolphin"; }
        { app_id = "org.kde.polkit-kde-authentication-agent-1"; }
        { app_id = "org.oe-f.openboard"; }
        { app_id = "pavucontrol"; }
        { app_id = "setroubleshoot"; }
        { app_id = "simple-scan"; }
        { app_id = "tlp-ui"; }
        { app_id = "Waydroid"; }
        { app_id = "xfce-polkit"; }
        { app_id = "zoom"; }
        {
          class = "jetbrains-(.*)";
          title = "splash";
        }
        {
          class = "jetbrains-(.*)";
          title = "Welcome to (.*)";
        }
        {
          class = "Steam";
          title = "Steam - News(.*)";
        }
        { window_role = "bubble"; }
        { window_role = "pop-up"; }
        { window_role = "Preferences"; }
        { window_role = "task_dialog"; }
        { window_type = "dialog"; }
        { window_type = "menu"; }
      ];

      ##############################
      #
      ## Startup
      #
      ##############################
      startup = [
        #~~~ initial
        {
          command = "systemctl --user import-environment ${builtins.toString config.wayland.windowManager.sway.systemd.variables}";
        }

        #~~~ startup apps
        {
          command = "${swayidle} -w timeout 120 '${home}/.local/bin/powermenu --lock' timeout 140 '${swaymsg} output * dpms off' resume '${swaymsg} output * dpms on'";
        }
        { command = "${tmux} new-session -ds daemonmodetmux"; }
        { command = "${wlsunset} -S '07:00' -s '19:00'"; }
        {
          command = "${home}/.local/bin/tmux-server";
          always = true;
        }
        {
          command = "${home}/.config/sway/scripts.d/workspace.sh init 1";
        }

        #~~~ others
        { command = "${home}/.config/sway/scripts.d/autostart"; }
      ];
    };

    ##############################
    #
    ## Extra Config
    #
    ##############################
    extraConfig = ''
      #~~~ window
      default_border                                                      pixel 5
      default_floating_border                                             none
      hide_edge_borders --i3                                              none

      #~~~ window rules
      for_window [app_id="flameshot" title="flameshot"]                   fullscreen disable, move absolute position 0 0
      for_window [shell="xwayland"]                                       title_format "[X] %title", border pixel 8
      for_window [app_id="${termid}" title="${config.preferences.mediaplayer}"]                       resize set 50ppt 50ppt, floating enable
      for_window [app_id="${termid}" title="wttr.in"]                       resize set 48ppt 65ppt, floating enable
      for_window [app_id="${termid}" title="nmtui"]                         resize set 50ppt 50ppt, floating enable

      #~~~ other
      include ${config.home.homeDirectory}/.config/sway/config.d/*
    '';
    extraConfigEarly = ''
      #~~~ sway
      set $altMod        Mod1

      #~~~ apps
      set $browser       ${flatpak} run io.gitlab.librewolf-community
      set $filemanager   ${dolphin}
      set $mediaplayer   ${mpv}
    '';
  };
}
