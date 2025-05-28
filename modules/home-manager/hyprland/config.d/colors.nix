{ config, ... }:

{
  wayland.windowManager.hyprland.settings = with config.lib.stylix.colors; {
    "$background" = "rgb(${base00})";
    "$foreground" = "rgb(${base05})";
    "$active" = "rgb(${base0D})";
    "$inactive" = "rgb(${base03})";
    "$urgent" = "rgb(${base0C})";
    "$primary" = "rgb(${base05})";
    "$secondary" = "rgb(${base0D})";
    env = [
      "HYPRCURSOR_THEME,${config.stylix.cursor.name}"
      "HYPRCURSOR_SIZE,${builtins.toString config.stylix.cursor.size}"
    ];
    general = {
      "col.active_border" = "$active $secondary";
      "col.inactive_border" = "$inactive";
    };
  };
}
