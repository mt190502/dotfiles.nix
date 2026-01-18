{ config, ... }:

let
  inherit (config.wayland.windowManager.sway.config) modifier;
in
{
  wayland.windowManager.sway = {
    config = {
      bars = [
        {
          command = "true";
          position = "top";
          workspaceButtons = true;
        }
      ];
      floating.border = 5;
      floating.modifier = "${modifier}";
      focus.newWindow = "focus";
      gaps = {
        inner = 5;
        outer = 0;
      };
      window.border = 0;
      workspaceLayout = "tabbed";
    };
    extraConfig = ''
      #~~~ window
      default_border                                   pixel 5
      default_floating_border                          none
      hide_edge_borders --i3                           none

      #~~~ window rules
      for_window [app_id="flameshot" title="flameshot"]           fullscreen disable, move absolute position 0 0
      for_window [shell="xwayland"]                               title_format "[X] %title", border pixel 8
      for_window [app_id="Alacritty" title="ncmpcpp"]             resize set 50ppt 50ppt, floating enable
      for_window [app_id="Alacritty" title="wttr.in"]             resize set 48ppt 65ppt, floating enable
      for_window [app_id="Alacritty" title="nmtui"]               resize set 50ppt 50ppt, floating enable

      #~~~ other
      include ${config.home.homeDirectory}/.config/sway/config.d/*
    '';
  };
}
