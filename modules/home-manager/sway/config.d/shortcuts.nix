{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  modifier = config.wayland.windowManager.sway.config.modifier;
  menu = config.wayland.windowManager.sway.config.menu;
  home = config.home.homeDirectory;
in
{
  wayland.windowManager.sway.config = {
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
        "${modifier}+shift+s" = "exec ${home}/.local/bin/grimshot -r; mode 'default'";
        "a" = " exec ${home}/.local/bin/grimshot -a; mode 'default'";
        "f" = " exec ${home}/.local/bin/grimshot -f; mode 'default'";
        "Return" = "mode 'default'";
        "Escape" = "mode 'default'";
      };
    };
    keybindings =
      let
        alacritty = lib.getExe config.wrapped.alacritty;
        brightnessctl = lib.getExe pkgs.brightnessctl;
        cliphist = lib.getExe pkgs.cliphist;
        pactl = lib.getExe' pkgs.pulseaudio "pactl";
        playerctl = lib.getExe pkgs.playerctl;
        swaymsg = lib.getExe' config.wrapped.sway "swaymsg";
        tmux = lib.getExe pkgs.tmux;
        wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
        wofi = lib.getExe pkgs.wofi;
      in
      {
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
          "exec ${swaymsg} input 'type:keyboard' xkb_switch_layout next && ${swaymsg} floating toggle"; # ~ https://github.com/swaywm/sway/issues/8403
        "${modifier}+shift+1" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 1";
        "${modifier}+shift+2" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 2";
        "${modifier}+shift+3" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 3";
        "${modifier}+shift+4" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 4";
        "${modifier}+shift+5" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 5";
        "${modifier}+shift+6" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 6";
        "${modifier}+shift+7" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 7";
        "${modifier}+shift+8" = "exec ${home}/.config/sway/scripts.d/workspace.sh move-container 8";

        #~~~ workspace
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+1" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 1";
        "${modifier}+2" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 2";
        "${modifier}+3" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 3";
        "${modifier}+4" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 4";
        "${modifier}+5" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 5";
        "${modifier}+6" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 6";
        "${modifier}+7" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 7";
        "${modifier}+8" = "exec ${home}/.config/sway/scripts.d/workspace.sh switch 8";

        #~~~ sound
        "XF86AudioRaiseVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec ${pactl} set-sink-mute @DEFAULT_SINK@ toggle";

        #~~~ brightness (for Laptops)
        "XF86MonBrightnessUp" = "exec ${brightnessctl} set +5%";
        "XF86MonBrightnessDown" = "exec ${brightnessctl} set 5%-";

        #~~~ clipboard
        "${modifier}+v" = "exec ${cliphist} list | ${wofi} --show dmenu | ${cliphist} decode | ${wl-copy}";
        "${modifier}+shift+v" = "exec ${cliphist} wipe";

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
        "${modifier}+Return" = "exec ${alacritty} -e bash -c '${tmux} attach -t daemonmodetmux'";
        "${modifier}+d" = "exec ${home}/.local/bin/program-toggler ${menu}";
        "${modifier}+l" =
          if cfg.prefered-lock-app == "swaylock" then
            "exec ${home}/.local/bin/blurlock"
          else
            "exec ${cfg.prefered-lock-app}";
        "${modifier}+period" = "exec ${home}/.local/bin/program-toggler ${home}/.local/bin/wofimoji";
        "${modifier}+shift+d" =
          "exec ${home}/.local/bin/program-toggler ${home}/.local/bin/easy-tesseract -e";
        "${modifier}+shift+f" =
          "exec ${home}/.local/bin/program-toggler ${home}/.local/bin/easy-tesseract -t";
        "ctrl+period" = "exec ${home}/.config/sway/scripts.d/dropdown.sh";
      };
  };
}
