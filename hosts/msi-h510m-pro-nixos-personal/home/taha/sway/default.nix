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
  wayland.windowManager.sway.config = lib.mkIf (config.preferences.desktopenv == "sway") {
    keybindings = {
      "${modifier}+g" = "exec ${onepass} --quick-access";
    };
    output = {
      "*" = {
        bg = "${config.stylix.image} fill";
      };
      "HDMI-A-4" = {
        mode = "1920x1080";
        position = "0,0";
      };
      "DP-2" = {
        mode = "1920x1080";
        position = "1920,0";
      };
    };
    startup = [
      {
        command = "${config.bin.solaar} -w hide";
      }
      {
        command = "${onepass} --silent";
      }
    ];
  };
}
