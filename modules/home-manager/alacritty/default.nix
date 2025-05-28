{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager.alacritty;
in
{
  options.moduleopts.home-manager.alacritty = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "alacritty";
    };
    theme = lib.mkOption {
      type = lib.types.str;
      default = "vibrant-ink";
      description = "theme";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      package = config.wrapped.alacritty;
      settings = {
        font.size = config.stylix.fonts.sizes.terminal;
        font.normal = {
          family = config.stylix.fonts.monospace.name;
          style = lib.mkForce "Bold";
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
        terminal.shell.program = lib.getExe pkgs.tmux;
        window.dynamic_title = true;
        general.import = [
          inputs.alacritty-theme.packages."${pkgs.system}"."${cfg.theme}"
        ];
      };
    };
  };
}
