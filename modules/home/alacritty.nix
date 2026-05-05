{ config, lib, ... }:

{
  config = {
    preferences.terminal = lib.mkDefault "alacritty";
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          size = config.fontcfg.sizes.terminal;
          normal = {
            family = config.fontcfg.monospace.name;
            style = lib.mkForce "Bold";
          };
          bold = {
            family = config.fontcfg.monospace.name;
            style = "Bold";
          };
          italic = {
            family = config.fontcfg.monospace.name;
            style = "Italic";
          };
          bold_italic = {
            family = config.fontcfg.monospace.name;
            style = "Bold Italic";
          };
        };
        terminal.shell.program = config.bin.tmux;
        window.dynamic_title = true;
      };
    };
  };
}
