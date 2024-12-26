{ config, lib, ... }:

{
  options.pkgconfig.fastfetch = {
    enable = lib.mkEnableOption "Enable fastfetch configuration.";
  };
  config.programs.fastfetch = {
    enable = config.pkgconfig.fastfetch.enable;

    settings = {
      display = {
        separator = ": ";
        constants = [ "──────────────────────────────" ];
      };

      modules = [
        { type = "title"; }
        { type = "separator"; }
        {
          type = "os";
          key = "OS ";
        }
        {
          type = "host";
          key = "HO ";
        }
        {
          type = "kernel";
          key = "KR ";
        }
        {
          type = "uptime";
          key = "UP ";
        }
        {
          type = "packages";
          key = "PK ";
        }
        {
          type = "shell";
          key = "SH ";
        }
        {
          type = "display";
          key = "RE ";
        }
        {
          type = "de";
          key = "DE ";
        }
        {
          type = "wm";
          key = "WM ";
        }
        {
          type = "wmtheme";
          key = "WT ";
        }
        {
          type = "theme";
          key = "TH ";
        }
        {
          type = "icons";
          key = "IC ";
        }
        {
          type = "font";
          key = "FO ";
        }
        {
          type = "cursor";
          key = "CR ";
        }
        {
          type = "terminal";
          key = "TE ";
        }
        {
          type = "terminalfont";
          key = "TF ";
        }
        {
          type = "cpu";
          key = "CPU";
        }
        {
          type = "gpu";
          key = "GPU";
        }
        {
          type = "memory";
          key = "MEM";
        }
        { type = "break"; }
        { type = "colors"; }
      ];
    };
  };
}
