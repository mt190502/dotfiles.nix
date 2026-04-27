{
  config,
  osConfig,
  lib,
  ...
}:

let
  inherit (config.wayland.windowManager.sway.config) modifier;
  onepass = lib.getExe' osConfig.programs._1password-gui.package "1password";
in
{
  wayland.windowManager.sway.config = lib.mkIf (config.preferences.wm == "sway") {
    keybindings = {
      "${modifier}+g" = "exec ${onepass}/bin/1password --quick-access";
    };
    output = {
      "*" = {
        bg = "${config.stylix.image} fill";
      };
      "eDP-1" = {
        mode = "1920x1200";
        position = "0,0";
      };
    };
    startup = [
      {
        command = "${config.bin.solaar} -w hide";
      }
      {
        command = "${onepass}/bin/1password --silent";
      }
    ];
  };
}
