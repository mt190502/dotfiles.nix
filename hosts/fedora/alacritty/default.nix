{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  options.pkgconfig.alacritty = {
    enable = lib.mkEnableOption "Enable alacritty configuration.";
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
      font.size = config.stylix.fonts.sizes.terminal;
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
      terminal.shell.program = lib.getExe pkgs.tmux;
      window.dynamic_title = true;

      general.import = [
        inputs.alacritty-theme.packages."${pkgs.system}"."${config.pkgconfig.alacritty.theme}"
      ];
    };
  };
}
