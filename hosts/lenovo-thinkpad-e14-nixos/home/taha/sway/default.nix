{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  onepass = osConfig.moduleopts.nixos.onepassword.package;
  modifier = config.wayland.windowManager.sway.config.modifier;
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
      "eDP-1" = {
        mode = "1920x1200";
        position = "0,0";
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
