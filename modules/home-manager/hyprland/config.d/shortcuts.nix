{
  config,
  lib,
  pkgs,
  ...
}:

let
  modifier = config.wayland.windowManager.hyprland.settings."$mod";
  alt = config.wayland.windowManager.hyprland.settings."$alt";
  home = config.home.homeDirectory;
in
{
  wayland.windowManager.hyprland.settings = {
    binds = {
      workspace_back_and_forth = true;
    };
    bind = [
      #~~~ window
      "${modifier}, f, fullscreen"
      "${modifier} SHIFT, SPACE, togglefloating"

      #~~~ sound
      ", XF86AudioRaiseVolume, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%"
      ", XF86AudioLowerVolume, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%"
      ", XF86AudioMute, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle"

      #~~~ brightness (for Laptops)
      ", XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} set +5%"
      ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} set 5%-"

      #~~~ clipboard
      "${modifier}, v, exec, ${lib.getExe pkgs.cliphist} list | ${lib.getExe pkgs.wofi} --show dmenu | ${lib.getExe pkgs.cliphist} decode | ${pkgs.wl-clipboard}/bin/wl-copy"
      "${modifier} SHIFT, v, exec, ${pkgs.cliphist}/bin/cliphist wipe"

      #~~~ playerctl
      ", XF86AudioPlay, exec, ${lib.getExe pkgs.playerctl} play-pause"
      ", XF86AudioPause, exec, ${lib.getExe pkgs.playerctl} play-pause"
      ", XF86AudioNext, exec, ${lib.getExe pkgs.playerctl} next"
      ", XF86AudioPrev, exec, ${lib.getExe pkgs.playerctl} previous"
      "${alt}, Left, exec, ${lib.getExe pkgs.playerctl} previous"
      "${alt}, Right, exec, ${lib.getExe pkgs.playerctl} next"

      #~~~ sway
      "${modifier} SHIFT, r, exec, ${config.wrapped.hyprland}/bin/hyprctl reload"
      "${modifier}, q, killactive"

      #~~~ other
      "${modifier}, Return, exec, ${config.wrapped.alacritty}/bin/alacritty -e bash -c '${pkgs.tmux}/bin/tmux attach -t daemonmodetmux'"
      "${modifier}, d, exec, ${home}/.config/hypr/scripts.d/programtoggle.sh $menu"
      "${modifier}, l, exec, ${home}/.config/hypr/scripts.d/powermenu.sh --lock"
      "${modifier}, period, exec, ${home}/.config/hypr/scripts.d/programtoggle.sh ${home}/.config/hypr/scripts.d/wofimoji.sh"
      "${modifier} SHIFT, d, exec, ${home}/.config/hypr/scripts.d/programtoggle.sh ${home}/.config/hypr/scripts.d/tesseract.sh -e"
      "${modifier} SHIFT, f, exec, ${home}/.config/hypr/scripts.d/programtoggle.sh ${home}/.config/hypr/scripts.d/tesseract.sh -t"
    ];
  };
}
