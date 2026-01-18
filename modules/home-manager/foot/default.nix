{ config, lib, ... }:

let
  cfg = config.moduleopts.home-manager;
  size = builtins.toString config.stylix.fonts.sizes.terminal;
in
{
  config = lib.mkIf (cfg.preferred.terminal == "foot") {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          font = lib.mkForce "${config.stylix.fonts.monospace.name}:weight=Bold:size=${size}";
          font-bold = lib.mkForce "${config.stylix.fonts.monospace.name}:weight=Bold:size=${size}";
          font-italic = lib.mkForce "${config.stylix.fonts.monospace.name}:slant=Italic:size=${size}";
          font-bold-italic = lib.mkForce "${config.stylix.fonts.monospace.name}:weight=Bold:slant=Italic:size=${size}";
          resize-by-cells = "no";
        };
        cursor = {
          style = "block";
        };
        key-bindings = {
          font-increase = "Control+Shift+plus";
          font-decrease = "Control+Shift+underscore";
          font-reset = "Control+0";
        };
      };
    };
  };
}
