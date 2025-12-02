{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  cfg = config.moduleopts.home-manager;
  getVicinaeExtensions =
    names:
    map (name: inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}.${name}) names;
in
{
  config = lib.mkIf (cfg.preferred.menu == "vicinae") {
    programs.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
      extensions =
        (getVicinaeExtensions [
          "bluetooth"
          "nix"
          "ssh"
          "stocks"
        ]);
      themes = {
        stylix = with config.stylix; {
          meta = {
            version = 1;
            name = "Stylix";
            description = "Stylix theme for Vicinae";
            variant = if polarity == "either" then "light" else polarity;
          };
          colors =
            with config.stylix.customColors.withHashtag;
            with config.lib.stylix.colors.withHashtag;
            {
              core = {
                inherit background border;
                accent = active;
                foreground = text;
                secondary_background = inactive;
              };
              accents = {
                blue = base0D;
                cyan = base0C;
                green = base0B;
                magenta = base0E;
                orange = base09;
                purple = base0E;
                red = base08;
                yellow = base0A;
              };
              list.item = {
                selection = {
                  background.name = base02;
                  secondary_background = base03;
                };
                hover.background = base01;
              };
            };
        };
      };
    };
  };
}
