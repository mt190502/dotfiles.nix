{
  config,
  lib,
  pkgs,
  ...
}:

{
  #~ nixGL wrapped packages ~#
  options.wrappedPkgs.alacritty = lib.mkOption {
    default = (config.lib.nixGL.wrap pkgs.alacritty);
    type = lib.types.package;
  };
  options.wrappedPkgs.imagemagick = lib.mkOption {
    default = (config.lib.nixGL.wrap pkgs.imagemagick);
    type = lib.types.package;
  };
  options.wrappedPkgs.imv = lib.mkOption {
    default = (config.lib.nixGL.wrap pkgs.imv);
    type = lib.types.package;
  };
  options.wrappedPkgs.kdeconnect = lib.mkOption {
    default = (config.lib.nixGL.wrap pkgs.kdePackages.kdeconnect-kde);
    type = lib.types.package;
  };
  options.wrappedPkgs.mpv = lib.mkOption {
    default = (config.lib.nixGL.wrap pkgs.mpv);
    type = lib.types.package;
  };
  options.wrappedPkgs.nwg-displays = lib.mkOption {
    default = (config.lib.nixGL.wrap pkgs.nwg-displays);
    type = lib.types.package;
  };
  options.wrappedPkgs.qt5ct = lib.mkOption {
    default = (config.lib.nixGL.wrap pkgs.libsForQt5.qt5ct);
    type = lib.types.package;
  };
  options.wrappedPkgs.qt6ct = lib.mkOption {
    default = (config.lib.nixGL.wrap pkgs.kdePackages.qt6ct);
    type = lib.types.package;
  };
  options.wrappedPkgs.sway = lib.mkOption {
    default = (config.lib.nixGL.wrap pkgs.swayfx);
    type = lib.types.package;
  };
  options.wrappedPkgs.swaylock = lib.mkOption {
    default = (config.lib.nixGL.wrap pkgs.swaylock);
    type = lib.types.package;
  };

  #~ other wrapped packages ~#
  options.wrappedPkgs.dolphin = lib.mkOption {
    default = (
      config.lib.nixGL.wrap (
        pkgs.symlinkJoin {
          name = "dolphin";
          paths = [ pkgs.kdePackages.dolphin ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/dolphin \
              --set QT_STYLE_OVERRIDE kvantum \
              --set XDG_CURRENT_DESKTOP KDE
          '';
        }
      )
    );
    type = lib.types.package;
  };
  options.wrappedPkgs.flameshot = lib.mkOption {
    default = (
      pkgs.symlinkJoin {
        name = "flameshot";
        paths = [
          (config.lib.nixGL.wrap (
            pkgs.flameshot.overrideAttrs (oldAttrs: {
              src = pkgs.fetchFromGitHub {
                owner = "flameshot-org";
                repo = "flameshot";
                rev = "10d12e0";
                sha256 = "sha256-3ujqwiQrv/H1HzkpD/Q+hoqyrUdO65gA0kKqtRV0vmw=";
              };
              cmakeFlags = [
                "-DUSE_WAYLAND_CLIPBOARD=1"
                "-DUSE_WAYLAND_GRIM=1"
              ];
              buildInputs = oldAttrs.buildInputs ++ [ pkgs.libsForQt5.kguiaddons ];
            })
          ))
        ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/flameshot \
            --set QT_STYLE_OVERRIDE kvantum \
            --set XDG_CURRENT_DESKTOP KDE
        '';
      }
    );
    type = lib.types.package;
  };
  options.wrappedPkgs.waybar = lib.mkOption {
    default = (
      pkgs.symlinkJoin {
        name = "waybar";
        paths = [ pkgs.waybar ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/waybar \
            --set GTK_THEME Adwaita:dark
        '';
      }
    );
    type = lib.types.package;
  };
}
