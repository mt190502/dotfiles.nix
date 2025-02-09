{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  options.pkgconfig.alacritty = {
    theme = lib.mkOption {
      type = lib.types.str;
      default = "vibrant-ink";
      description = "Alacritty theme.";
    };
  };
  config.programs.alacritty = {
    enable = true;
    package = config.wrappedPkgs.alacritty;

    settings = {
      #~ Font
      font.size = config.stylix.fonts.sizes.terminal;
      font.normal = {
        family = config.stylix.fonts.monospace.name;
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
