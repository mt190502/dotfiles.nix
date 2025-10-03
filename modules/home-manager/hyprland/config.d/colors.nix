{ config, ... }:

{
  wayland.windowManager.hyprland.settings = with config.stylix.customColors.raw; {
    "$background" = "rgb(${background})";
    "$foreground" = "rgb(${text})";
    "$active" = "rgb(${active})";
    "$inactive" = "rgb(${inactive})";
    "$urgent" = "rgb(${urgent})";
    env = [
      "HYPRCURSOR_THEME,${config.stylix.cursor.name}"
      "HYPRCURSOR_SIZE,${builtins.toString config.stylix.cursor.size}"
    ];
    general = {
      "col.active_border" = "$active";
      "col.inactive_border" = "$inactive";
    };
  };
}
