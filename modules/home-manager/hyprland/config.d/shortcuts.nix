{
  config,
  lib,
  pkgs,
  ...
}:

let
  alt = config.wayland.windowManager.hyprland.settings."$alt";
  cfg = config.moduleopts.home-manager;
  home = config.home.homeDirectory;
  menu = config.wayland.windowManager.hyprland.settings."$menu";
  modifier = config.wayland.windowManager.hyprland.settings."$mod";
  term =
    title: command:
    (
      if cfg.preferred.terminal == "alacritty" then
        lib.getExe config.wrapped.alacritty + " -T " + title + " -e " + command
      else
        throw "Unsupported terminal: ${cfg.preferred.terminal}"
    );
in
{
  wayland.windowManager.hyprland.settings = {
    binds = {
      workspace_back_and_forth = true;
    };
    bind =
      let
        brightnessctl = lib.getExe pkgs.brightnessctl;
        cliphist = lib.getExe pkgs.cliphist;
        hyprctl = lib.getExe' config.wrapped.hyprland "hyprctl";
        pactl = lib.getExe' pkgs.pulseaudio "pactl";
        playerctl = lib.getExe pkgs.playerctl;
        tmux = lib.getExe pkgs.tmux;
        wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
        wofi = lib.getExe pkgs.wofi;
      in
      [
        #~~~ window
        "${modifier}, f, fullscreen"
        "${modifier} SHIFT, SPACE, togglefloating"
        "${modifier} SHIFT, 1, exec, ${home}/.config/hypr/scripts.d/workspace.sh move-container 1"
        "${modifier} SHIFT, 2, exec, ${home}/.config/hypr/scripts.d/workspace.sh move-container 2"
        "${modifier} SHIFT, 3, exec, ${home}/.config/hypr/scripts.d/workspace.sh move-container 3"
        "${modifier} SHIFT, 4, exec, ${home}/.config/hypr/scripts.d/workspace.sh move-container 4"
        "${modifier} SHIFT ${alt}, 1, exec, ${home}/.config/hypr/scripts.d/workspace.sh move-container 5"
        "${modifier} SHIFT ${alt}, 2, exec, ${home}/.config/hypr/scripts.d/workspace.sh move-container 6"
        "${modifier} SHIFT ${alt}, 3, exec, ${home}/.config/hypr/scripts.d/workspace.sh move-container 7"
        "${modifier} SHIFT ${alt}, 4, exec, ${home}/.config/hypr/scripts.d/workspace.sh move-container 8"

        #~~~ workspace
        "${modifier}, 1, exec, ${home}/.config/hypr/scripts.d/workspace.sh switch 1"
        "${modifier}, 2, exec, ${home}/.config/hypr/scripts.d/workspace.sh switch 2"
        "${modifier}, 3, exec, ${home}/.config/hypr/scripts.d/workspace.sh switch 3"
        "${modifier}, 4, exec, ${home}/.config/hypr/scripts.d/workspace.sh switch 4"
        "${modifier} ${alt}, 1, exec, ${home}/.config/hypr/scripts.d/workspace.sh switch 5"
        "${modifier} ${alt}, 2, exec, ${home}/.config/hypr/scripts.d/workspace.sh switch 6"
        "${modifier} ${alt}, 3, exec, ${home}/.config/hypr/scripts.d/workspace.sh switch 7"
        "${modifier} ${alt}, 4, exec, ${home}/.config/hypr/scripts.d/workspace.sh switch 8"

        #~~~ sound
        ", XF86AudioRaiseVolume, exec, ${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
        ", XF86AudioLowerVolume, exec, ${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
        ", XF86AudioMute, exec, ${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"

        #~~~ brightness (for Laptops)
        ", XF86MonBrightnessUp, exec, ${brightnessctl} set +5%"
        ", XF86MonBrightnessDown, exec, ${brightnessctl} set 5%-"

        #~~~ playerctl
        ", XF86AudioPlay, exec, ${playerctl} play-pause"
        ", XF86AudioPause, exec, ${playerctl} play-pause"
        ", XF86AudioNext, exec, ${playerctl} next"
        ", XF86AudioPrev, exec, ${playerctl} previous"
        "${alt}, Left, exec, ${playerctl} previous"
        "${alt}, Right, exec, ${playerctl} next"

        #~~~ sway
        "${modifier} SHIFT, r, exec, ${hyprctl} reload"
        "${modifier}, q, killactive"

        #~~~ other
        "${modifier}, Return, exec, ${term "bash" "${tmux} attach -t daemonmodetmux"}"
      ]
      ++ (
        if cfg.preferred.menu == "wofi" then
          [
            #~~~ clipboard (wofi)
            "${modifier}, v, exec, ${cliphist} list | ${wofi} --show dmenu | ${cliphist} decode | ${wl-copy}"
            "${modifier} SHIFT, v, exec, ${cliphist} wipe"

            #~~~ others
            "${modifier}, d, exec, ${home}/.local/bin/program-toggler ${menu}"
            "${modifier}, period, exec, ${home}/.local/bin/program-toggler ${home}/.local/bin/wofimoji"
            "${modifier} SHIFT, d, exec, ${home}/.local/bin/program-toggler ${home}/.local/bin/easy-tesseract -e"
            "${modifier} SHIFT, f, exec, ${home}/.local/bin/program-toggler ${home}/.local/bin/easy-tesseract -t"
          ]
        else if cfg.preferred.menu == "vicinae" then
          [
            #~~~ clipboard (vicinae)
            "${modifier}, v, exec, ${menu} 'vicinae://extensions/vicinae/clipboard/history'"

            #~~~ others
            "${modifier}, d, exec, ${menu}"
          ]
        else
          [ ]
      );
  };
}
