{ ... }:

{
  wayland.windowManager.sway.config.input = {
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
}
