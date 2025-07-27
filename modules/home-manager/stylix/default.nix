{
  config,
  inputs,
  lib,
  pkgs,
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
          text = if builtins.isAttrs config.stylix.base16Scheme then withHashtag.base05 else "#FFFFFF";
          urgent = withHashtag.base08;
        };
        withHex = rec {
          active = base03-hex;
          background = base00-hex;
          border = active;
          inactive = base01-hex;
          text = if builtins.isAttrs config.stylix.base16Scheme then base05-hex else "FFFFFF";
          urgent = base08-hex;
        };
        raw = rec {
          active = base03;
          background = base00;
          border = active;
          inactive = base01;
          text = if builtins.isAttrs config.stylix.base16Scheme then base05 else "FFFFFF";
          urgent = base08;
        };
        description = "Custom colors to be used in stylix.";
      };
    };
  };
  config.stylix = {
    enable = true;
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
        name = "Ubuntu Nerd Font Medium";
        package = inputs.self.packages."${pkgs.system}".ubuntu-fonts-google;
      };
      serif = {
        name = "Ubuntu Nerd Font Medium";
        package = inputs.self.packages."${pkgs.system}".ubuntu-fonts-google;
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
      gtk.extraCss = ''
        @define-color light_1 #ffffff;
        @define-color dark_5 #ffffff;
      '';
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
    };
  };
}
