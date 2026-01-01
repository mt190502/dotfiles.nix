{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  inherit (config.wayland.windowManager.sway.config) modifier;
  cfg = config.moduleopts.home-manager;
  onepass = osConfig.moduleopts.nixos.onepassword.package;
in
{
  wayland.windowManager.sway.config = lib.mkIf (cfg.preferred.wm == "sway") {
    keybindings = {
      "${modifier}+g" = "exec ${onepass}/bin/1password --quick-access";
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
        command = "${pkgs.solaar}/bin/solaar -w hide";
      }
      {
        command = "${onepass}/bin/1password --silent";
      }
    ];
  };
}
