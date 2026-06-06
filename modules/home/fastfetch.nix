{
  lib,
  flakeName,
  pkgs,
  ...
}:

{
  programs.fastfetch = {
    enable = true;
    package = pkgs.fastfetch.override (
      lib.optionalAttrs (lib.hasSuffix "server" flakeName) {
        brightnessSupport = false;
        dbusSupport = false;
        enlightenmentSupport = false;
        gnomeSupport = false;
        imageSupport = false;
        openclSupport = false;
        openglSupport = false;
        vulkanSupport = false;
        waylandSupport = false;
        x11Support = false;
        xfceSupport = false;
      }
    );
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
