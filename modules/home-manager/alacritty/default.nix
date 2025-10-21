{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
in
{
  options.moduleopts.home-manager.alacritty = {
    theme = lib.mkOption {
      type = lib.types.str;
      default = "vibrant-ink";
      description = "theme";
    };
  };
  config = lib.mkIf (cfg.preferred.terminal == "alacritty") {
    programs.alacritty = {
      enable = true;
      package = config.wrapped.alacritty;
      settings = {
        font = {
          size = config.stylix.fonts.sizes.terminal;
          normal = {
            family = config.stylix.fonts.monospace.name;
            style = lib.mkForce "Bold";
          };
          bold = {
            family = "Hack";
            style = "Bold";
          };
          italic = {
            family = "Hack";
            style = "Italic";
          };
          bold_italic = {
            family = "Hack";
            style = "Bold Italic";
          };
        };
        terminal.shell.program = lib.getExe pkgs.tmux;
        window.dynamic_title = true;
        general.import = [
          inputs.alacritty-theme.packages."${pkgs.system}"."${cfg.alacritty.theme}"
        ];
      };
    };
  };
}
