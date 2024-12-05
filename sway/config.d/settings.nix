{ config, ... }:

let modifier = config.wayland.windowManager.sway.config.modifier;
in {
  wayland.windowManager.sway = {
    config = {
      floating.modifier = "${modifier}";
      bars = [{
        position = "top";
        command = "waybar";
      }];
      gaps = {
        inner = 5;
        outer = 0;
      };
      window.hideEdgeBorders = "none";
      workspaceLayout = "tabbed";
      menu = "wofi --prompt 'Search Apps' --show drun";
      terminal = "alacritty";
      seat = { "*" = { xcursor_theme = "Adwaita 16"; }; };
    };
    extraConfig = ''
      #~~~ window
      default_border                                   pixel 5
      default_floating_border                          none

      #~~~ window rules
      for_window [app_id="flameshot" title="flameshot"]           fullscreen disable, move absolute position 0 0
      for_window [shell="xwayland"]                               title_format "[X] %title", border pixel 8
    '';
  };
}
