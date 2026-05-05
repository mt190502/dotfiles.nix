{
  config,
  inputs,
  lib,
  pkgs,
  system,
  ...
}:

{
  imports = [ inputs.stylix.homeModules.stylix ];
  options.stylix = {
    customColors = lib.mkOption {
      type = with lib.types; attrsOf (attrsOf str);
      default = with config.lib.stylix.colors; {
        withHashtag = rec {
          active = withHashtag.base03;
          background = withHashtag.base00;
          border = active;
          inactive = withHashtag.base01;
          text = withHashtag.base05;
          urgent = withHashtag.base08;
        };
        withHex = rec {
          active = base03-hex;
          background = base00-hex;
          border = active;
          inactive = base01-hex;
          text = base05-hex;
          urgent = base08-hex;
        };
        raw = rec {
          active = base03;
          background = base00;
          border = active;
          inactive = base01;
          text = base05;
          urgent = base08;
        };
        description = "Custom colors to be used in stylix.";
      };
    };
  };
  config = {
    fontcfg = lib.mkForce {
      monospace = {
        name = config.stylix.fonts.monospace.name;
        package = config.stylix.fonts.monospace.package;
        # name = "Scientifica Nerd Font";
        # package = pkgs.scientifica.overrideAttrs (o: {
        #   nativeBuildInputs = [ pkgs.nerd-font-patcher ];
        #   postInstall = ''
        #     mkdir -p $out/share/fonts/truetype/{scientifica,scientifica-nerd}
        #     mv $out/share/fonts/truetype/*.ttf $out/share/fonts/truetype/scientifica/
        #     for f in $out/share/fonts/truetype/scientifica/*.ttf; do
        #       nerd-font-patcher --complete --outputdir $out/share/fonts/truetype/scientifica-nerd/ $f
        #     done
        #   '';
        # });
      };
      sansSerif = {
        name = config.stylix.fonts.sansSerif.name;
        package = config.stylix.fonts.sansSerif.package;
      };
      serif = {
        name = config.stylix.fonts.serif.name;
        package = config.stylix.fonts.serif.package;
      };
      sizes = {
        applications = config.stylix.fonts.sizes.applications;
        terminal = config.stylix.fonts.sizes.terminal;
      };
    };
    cursorcfg = lib.mkForce {
      name = config.stylix.cursor.name;
      size = config.stylix.cursor.size;
      package = config.stylix.cursor.package;
    };
    iconthemecfg = lib.mkForce {
      dark = config.stylix.iconTheme.dark;
      light = config.stylix.iconTheme.light;
      package = config.stylix.iconTheme.package;
    };
    stylix = {
      enable = lib.mkIf (lib.hasSuffix "linux" system) true;
      # autoEnable = false;
      cursor = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 16;
      };
      fonts = {
        monospace = {
          name = "MesloLGS NF";
          package = pkgs.meslo-lgs-nf;
        };
        sansSerif = {
          name = "Ubuntu Nerd Font Medium";
          package = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".ubuntu-fonts-google;
        };
        serif = {
          name = "Ubuntu Nerd Font Medium";
          package = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".ubuntu-fonts-google;
        };
        sizes = {
          applications = 10;
          terminal = 9;
        };
      };
      iconTheme = {
        enable = true;
        package = pkgs.flat-remix-icon-theme;
        light = "Flat-Remix-Blue-Light";
        dark = "Flat-Remix-Blue-Dark";
      };
      polarity = "dark";
      targets = {
        hyprland.enable = false;
        mangohud.enable = false;
        k9s.enable = false;
        kde.enable = false;
        neovim.enable = false;
        nixvim.enable = false;
        qt.enable = false;
        sway.enable = false;
        swaylock.enable = false;
        swaync.enable = false;
        waybar.enable = false;
        wofi.enable = false;
        zed.enable = false;
      };
    };
  };
}
