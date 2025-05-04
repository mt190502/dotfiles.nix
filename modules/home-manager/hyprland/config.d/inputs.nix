{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "us,tr";
      kb_options = "grp:win_space_toggle";
      numlock_by_default = true;

      touchpad = {
        disable_while_typing = true;
        tap-to-click = true;
        natural_scroll = true;
        middle_button_emulation = true;
      };
    };
  };
}
