{ config, lib, pkgs, ... }:

{
  options.pkgconfig.alacritty = {
    enable = lib.mkEnableOption {
      type = lib.types.bool;
      default = true;
      description = "Enable alacritty configuration.";
    };
    theme = lib.mkOption {
      type = lib.types.str;
      default = "vibrant-ink";
      description = "Alacritty theme.";
    };
  };
  config.programs.alacritty = {
    enable = config.pkgconfig.alacritty.enable;
    package = config.lib.nixGL.wrap pkgs.alacritty;

    settings = {
      #~ Font
      font.size = 9;
      font.normal = {
        family = "MesloLGS NF";
        style = "Bold";
      };
      font.bold = {
        family = "Hack";
        style = "Bold";
      };
      font.italic = {
        family = "Hack";
        style = "Italic";
      };
      font.bold_italic = {
        family = "Hack";
        style = "Bold Italic";
      };

      #~ Settings
      terminal.shell.program = "tmux";
      window.dynamic_title = true;

      colors = (builtins.fromTOML (builtins.readFile
        ./themes/${config.pkgconfig.alacritty.theme}.toml)).colors;
    };
  };
}
