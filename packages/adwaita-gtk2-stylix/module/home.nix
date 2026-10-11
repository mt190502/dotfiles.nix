{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.adwaita-gtk2-stylix;
in
{
  options.adwaita-gtk2-stylix = {
    enable = lib.mkEnableOption "the Adwaita GTK2 theme recolored with the Stylix palette" // {
      default = config ? stylix && config.stylix ? customColors;
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = "adwaita-gtk2-stylix";
      description = "Name of the generated GTK2 theme.";
    };

    base16 = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = config.lib.stylix.colors;
      defaultText = lib.literalExpression "config.lib.stylix.colors";
      description = "Base16 palette (base00, base04, base05, base0D) used to recolor the theme.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../default.nix {
        inherit (cfg) base16;
        themeName = cfg.name;
      };
      defaultText = lib.literalExpression "pkgs.callPackage ../default.nix { inherit (cfg) base16; themeName = cfg.name; }";
      description = "The recolored Adwaita GTK2 theme.";
    };
  };

  config = lib.mkIf cfg.enable {
    gtk.gtk2 = {
      force = true;
      theme = {
        inherit (cfg) name package;
      };
    };

    home = {
      packages = [
        pkgs.gnome-themes-extra
        cfg.package
      ];
      sessionVariables.GTK_PATH = "${pkgs.gnome-themes-extra}/lib/gtk-2.0";
    };
  };
}
