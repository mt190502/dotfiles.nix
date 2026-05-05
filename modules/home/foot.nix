{ config, lib, ... }:

let
  size = builtins.toString config.fontcfg.sizes.terminal;
  font = config.fontcfg.monospace.name;
in
{
  config = {
    preferences.terminal = lib.mkDefault "foot";
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          font = lib.mkForce "${font}:weight=Bold:size=${size}";
          font-bold = lib.mkForce "${font}:weight=Bold:size=${size}";
          font-italic = lib.mkForce "${font}:slant=Italic:size=${size}";
          font-bold-italic = lib.mkForce "${font}:weight=Bold:slant=Italic:size=${size}";
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
