{ config, ... }:

let
  inherit (config.wayland.windowManager.sway.config) modifier;
  cfg = config.moduleopts.home-manager;
  term = (
    if cfg.preferred.terminal == "alacritty" then
      "Alacritty"
    else if cfg.preferred.terminal == "foot" then
      "footclient"
    else
      throw "Unsupported terminal: ${cfg.preferred.terminal}"
  );
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
      default_border                                                      pixel 5
      default_floating_border                                             none
      hide_edge_borders --i3                                              none

      #~~~ window rules
      for_window [app_id="flameshot" title="flameshot"]                   fullscreen disable, move absolute position 0 0
      for_window [shell="xwayland"]                                       title_format "[X] %title", border pixel 8
      for_window [app_id="${term}" title="${cfg.preferred.mediaplayer}"]                       resize set 50ppt 50ppt, floating enable
      for_window [app_id="${term}" title="wttr.in"]                       resize set 48ppt 65ppt, floating enable
      for_window [app_id="${term}" title="nmtui"]                         resize set 50ppt 50ppt, floating enable     

      #~~~ other
      include ${config.home.homeDirectory}/.config/sway/config.d/*
    '';
  };
}
