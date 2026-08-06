{
  config,
  inputs,
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.wayland.windowManager.sway.config) modifier;
  onepass = lib.getExe' osConfig.programs._1password-gui.package "1password";
  solaar = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.solaar-change-host;
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
        command = "${lib.getExe solaar} -w hide";
      }
      {
        command = "${onepass} --silent";
      }
    ];
  };
}
