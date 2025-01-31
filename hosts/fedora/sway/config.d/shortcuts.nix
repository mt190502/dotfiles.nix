{ config, pkgs, ... }:

let
  modifier = config.wayland.windowManager.sway.config.modifier;
  menu = config.wayland.windowManager.sway.config.menu;
  terminal = config.wayland.windowManager.sway.config.terminal;
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
        "${modifier}+shift+s" = "exec $HOME/.config/sway/scripts.d/screenshot.sh -r; mode 'default'";
        "a" = " exec $HOME/.config/sway/scripts.d/screenshot.sh -a; mode 'default'";
        "f" = " exec $HOME/.config/sway/scripts.d/screenshot.sh -f; mode 'default'";
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
      "${modifier}+Shift+space" = "floating toggle";
      "${modifier}+shift+1" = "exec $HOME/.config/sway/scripts.d/workspace.sh move-container 1";
      "${modifier}+shift+2" = "exec $HOME/.config/sway/scripts.d/workspace.sh move-container 2";
      "${modifier}+shift+3" = "exec $HOME/.config/sway/scripts.d/workspace.sh move-container 3";
      "${modifier}+shift+4" = "exec $HOME/.config/sway/scripts.d/workspace.sh move-container 4";
      "${modifier}+shift+5" = "exec $HOME/.config/sway/scripts.d/workspace.sh move-container 5";
      "${modifier}+shift+6" = "exec $HOME/.config/sway/scripts.d/workspace.sh move-container 6";
      "${modifier}+shift+7" = "exec $HOME/.config/sway/scripts.d/workspace.sh move-container 7";
      "${modifier}+shift+8" = "exec $HOME/.config/sway/scripts.d/workspace.sh move-container 8";

      #~~~ workspace
      "${modifier}+s" = "layout stacking";
      "${modifier}+w" = "layout tabbed";
      "${modifier}+e" = "layout toggle split";
      "${modifier}+1" = "exec $HOME/.config/sway/scripts.d/workspace.sh switch 1";
      "${modifier}+2" = "exec $HOME/.config/sway/scripts.d/workspace.sh switch 2";
      "${modifier}+3" = "exec $HOME/.config/sway/scripts.d/workspace.sh switch 3";
      "${modifier}+4" = "exec $HOME/.config/sway/scripts.d/workspace.sh switch 4";
      "${modifier}+5" = "exec $HOME/.config/sway/scripts.d/workspace.sh switch 5";
      "${modifier}+6" = "exec $HOME/.config/sway/scripts.d/workspace.sh switch 6";
      "${modifier}+7" = "exec $HOME/.config/sway/scripts.d/workspace.sh switch 7";
      "${modifier}+8" = "exec $HOME/.config/sway/scripts.d/workspace.sh switch 8";

      #~~~ sound
      "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";

      #~~~ brightness (for Laptops)
      "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
      "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

      #~~~ clipboard
      "${modifier}+v" =
        "exec ${pkgs.cliphist}/bin/cliphist list | ${pkgs.wofi} --show dmenu | ${pkgs.cliphist}/bin/cliphist decode | wl-copy";
      "${modifier}+shift+v" = "exec ${pkgs.cliphist}/bin/cliphist wipe";

      #~~~ playerctl
      "XF86AudioPlay" = "exec playerctl play-pause";
      "XF86AudioPause" = "exec playerctl play-pause";
      "XF86AudioNext" = "exec playerctl next";
      "XF86AudioPrev" = "exec playerctl previous";
      "$altMod+Left" = "exec playerctl previous";
      "$altMod+Right" = "exec playerctl next";

      #~~~ sway
      "${modifier}+Shift+r" = "reload";
      "${modifier}+q" = "kill";

      #~~~ other
      "${modifier}+Return" =
        "exec ${config.wrappedPkgs.${terminal}}/bin/alacritty -e bash -c '${pkgs.tmux}/bin/tmux new-window && ${pkgs.tmux}/bin/tmux attach -t daemonmodetmux'";
      "${modifier}+d" = "exec $HOME/.config/sway/scripts.d/programtoggle.sh ${menu}";
      "${modifier}+l" = "exec $HOME/.config/sway/scripts.d/powermenu.sh --lock";
      "${modifier}+period" =
        "exec $HOME/.config/sway/scripts.d/programtoggle.sh $HOME/.config/sway/scripts.d/wofimoji.sh";
      "${modifier}+shift+d" =
        "exec $HOME/.config/sway/scripts.d/programtoggle.sh $HOME/.config/sway/scripts.d/tesseract.sh -e";
      "${modifier}+shift+f" =
        "exec $HOME/.config/sway/scripts.d/programtoggle.sh $HOME/.config/sway/scripts.d/tesseract.sh -t";
      "ctrl+period" = "exec $HOME/.config/sway/scripts.d/dropdown_term.sh";
    };
  };
}
