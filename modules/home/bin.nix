{
  config,
  lib,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  mk = pkg: lib.getExe pkg;
  mk' = pkg: bin: lib.getExe' pkg bin;
in
{
  options = {
    bin = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Centralized binary path definitions";
    };
    fontcfg = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {
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
      description = "Centralized font configuration definitions";
    };
    cursorcfg = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {
        name = "Adwaita";
        size = 16;
        package = pkgs.adwaita-icon-theme;
      };
      description = "Centralized cursor theme configuration definitions";
    };
    iconthemecfg = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {
        dark = "Papirus-Dark";
        light = "Papirus-Light";
        package = pkgs.papirus-icon-theme;
      };
      description = "Centralized icon theme configuration definitions";
    };
  };
  config.bin = {
    alacritty = mk pkgs.alacritty;
    bash = mk' pkgs.bash "bash";
    curl = mk pkgs.curl;
    env = mk' pkgs.coreutils "env";
    fastfetch = mk config.programs.fastfetch.package;
    ffprobe = mk' pkgs.ffmpeg "ffprobe";
    gh = mk pkgs.gh;
    git = mk pkgs.git;
    grc = mk pkgs.grc;
    hugo = mk pkgs.hugo;
    imagemagick = mk pkgs.imagemagick;
    telnet = mk' pkgs.inetutils "telnet";
    jq = mk pkgs.jq;
    lsd = mk pkgs.lsd;
    mpv = mk pkgs.mpv;
    mpc = mk' pkgs.mpc "mpc";
    rmpc = mk pkgs.rmpc;
    ncmpcpp = mk pkgs.ncmpcpp;
    sh = mk' pkgs.bash "sh";
    tesseract = mk pkgs.tesseract;
    tmux = mk pkgs.tmux;
    trash = mk' pkgs.trash-cli "trash";
    translate-shell = mk pkgs.translate-shell;
    yt-dlp = mk pkgs.yt-dlp;
  }
  // (lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    dbus = mk' pkgs.dbus "dbus-update-activation-environment";
    systemctl = mk' pkgs.systemd "systemctl";
    systemd-env = "${pkgs.systemd}/lib/systemd/user-environment-generators/30-systemd-environment-d-generator";
  })
  // lib.optionalAttrs (pkgs.stdenv.hostPlatform.isLinux && config.preferences.desktopenv != "none") {
    brightnessctl = mk pkgs.brightnessctl;
    cht-sh = mk pkgs.cht-sh;
    neovide = mk pkgs.neovide;
    cliphist = mk pkgs.cliphist;
    dolphin = mk' config.wrapped.dolphin "dolphin";
    dragon-drop = mk pkgs.dragon-drop;
    flatpak = mk' pkgs.flatpak "flatpak";
    foot = mk pkgs.foot;
    footclient = mk' pkgs.foot "footclient";
    grim = mk pkgs.grim;
    imv = mk' pkgs.imv "imv-wayland";
    notify-send = mk' pkgs.libnotify "notify-send";
    makoctl = mk' pkgs.mako "makoctl";
    newt = mk' pkgs.newt "whiptail";
    nmeditor = mk' pkgs.networkmanagerapplet "nm-connection-editor";
    pactl = mk' pkgs.pulseaudio "pactl";
    pavucontrol = mk pkgs.pavucontrol;
    playerctl = mk pkgs.playerctl;
    powermenu = "${config.home.homeDirectory}/.local/bin/powermenu";
    slurp = mk pkgs.slurp;
    solaar = mk pkgs.solaar;
    swappy = mk pkgs.swappy;
    sway = mk' pkgs.sway "sway";
    swayidle = mk pkgs.swayidle;
    swaymsg = mk' pkgs.sway "swaymsg";
    swaynag = mk' pkgs.sway "swaynag";
    swaync = mk' pkgs.swaynotificationcenter "swaync-client";
    vicinae = mk pkgs-unstable.vicinae;
    wlsunset = mk pkgs.wlsunset;
    wl-copy = mk' pkgs.wl-clipboard "wl-copy";
    wofi = mk pkgs.wofi;
    wtype = mk pkgs.wtype;
    xev = mk pkgs.xev;
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    cht-sh = mk pkgs.cht-sh;
  };
}
