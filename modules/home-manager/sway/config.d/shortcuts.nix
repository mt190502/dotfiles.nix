{ config, lib, pkgs, ... }:

let
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
        "${modifier}+shift+s" = "exec ${home}/.config/sway/scripts.d/screenshot.sh -r; mode 'default'";
        "a" = " exec ${home}/.config/sway/scripts.d/screenshot.sh -a; mode 'default'";
        "f" = " exec ${home}/.config/sway/scripts.d/screenshot.sh -f; mode 'default'";
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
        "exec ${config.wrapped.sway}/bin/swaymsg input 'type:keyboard' xkb_switch_layout next && ${config.wrapped.sway}/bin/swaymsg floating toggle"; # ~ https://github.com/swaywm/sway/issues/8403
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
      "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";

      #~~~ brightness (for Laptops)
      "XF86MonBrightnessUp" = "exec ${lib.getExe pkgs.brightnessctl} set +5%";
      "XF86MonBrightnessDown" = "exec ${lib.getExe pkgs.brightnessctl} set 5%-";

      #~~~ clipboard
      "${modifier}+v" =
        "exec ${lib.getExe pkgs.cliphist} list | ${lib.getExe pkgs.wofi} --show dmenu | ${lib.getExe pkgs.cliphist} decode | ${pkgs.wl-clipboard}/bin/wl-copy";
      "${modifier}+shift+v" = "exec ${pkgs.cliphist}/bin/cliphist wipe";

      #~~~ playerctl
      "XF86AudioPlay" = "exec ${lib.getExe pkgs.playerctl} play-pause";
      "XF86AudioPause" = "exec ${lib.getExe pkgs.playerctl} play-pause";
      "XF86AudioNext" = "exec ${lib.getExe pkgs.playerctl} next";
      "XF86AudioPrev" = "exec ${lib.getExe pkgs.playerctl} previous";
      "$altMod+Left" = "exec ${lib.getExe pkgs.playerctl} previous";
      "$altMod+Right" = "exec ${lib.getExe pkgs.playerctl} next";

      #~~~ sway
      "${modifier}+Shift+r" = "reload";
      "${modifier}+q" = "kill";

      #~~~ other
      "${modifier}+d" = "exec ${home}/.config/sway/scripts.d/programtoggle.sh ${menu}";
      "${modifier}+l" = "exec ${home}/.config/sway/scripts.d/powermenu.sh --lock";
      "${modifier}+period" =
        "exec ${home}/.config/sway/scripts.d/programtoggle.sh ${home}/.config/sway/scripts.d/wofimoji.sh";
      "${modifier}+shift+d" =
        "exec ${home}/.config/sway/scripts.d/programtoggle.sh ${home}/.config/sway/scripts.d/tesseract.sh -e";
      "${modifier}+shift+f" =
        "exec ${home}/.config/sway/scripts.d/programtoggle.sh ${home}/.config/sway/scripts.d/tesseract.sh -t";
      "ctrl+period" = "exec ${home}/.config/sway/scripts.d/dropdown_term.sh";
    };
  };
}
