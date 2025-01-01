{ config, ... }:

let
  modifier = config.wayland.windowManager.sway.config.modifier;
in
{
  wayland.windowManager.sway = {
    config = {
      bars = [
        {
          command = "waybar";
          position = "top";
          workspaceButtons = true;
        }
      ];
      floating.border = 5;
      floating.modifier = "${modifier}";
      gaps = {
        inner = 5;
        outer = 0;
      };
      window.border = 0;
      workspaceLayout = "tabbed";
      menu = "wofi --prompt 'Search Apps' --show drun";
      terminal = "alacritty";
      # seat = {
      #   "*" = {
      #     xcursor_theme = "Adwaita 16";
      #   };
      # };
    };
    extraConfig = ''
      #~~~ window
      default_border                                   pixel 5
      default_floating_border                          none
      hide_edge_borders --i3                           none

      #~~~ window rules
      for_window [app_id="flameshot" title="flameshot"]           fullscreen disable, move absolute position 0 0
      for_window [shell="xwayland"]                               title_format "[X] %title", border pixel 8
    '';
  };
}
