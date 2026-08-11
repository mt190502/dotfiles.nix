{
  lib,
  pkgs,
  pkgs-unstable ? pkgs,
}:

let
  inherit (lib) getExe';
  binPkg = {
    "wl-copy" = {
      pkg = "wl-clipboard";
    };
    "wl-paste" = {
      pkg = "wl-clipboard";
    };
    "notify-send" = {
      pkg = "libnotify";
    };
    "makoctl" = {
      pkg = "mako";
    };
    "newt" = {
      pkg = "newt";
      bin = "whiptail";
    };
    "swaymsg" = {
      pkg = "sway";
    };
    "swaynag" = {
      pkg = "sway";
    };
    "swaync" = {
      pkg = "swaynotificationcenter";
      bin = "swaync-client";
    };
    "sh" = {
      pkg = "bash";
      bin = "sh";
    };
    "env" = {
      pkg = "coreutils";
      bin = "env";
    };
    "bash" = {
      pkg = "bash";
    };
    "pactl" = {
      pkg = "pulseaudio";
    };
    "ffprobe" = {
      pkg = "ffmpeg";
    };
    "telnet" = {
      pkg = "inetutils";
    };
    "trash" = {
      pkg = "trash-cli";
    };
    "systemctl" = {
      pkg = "systemd";
    };
    "vicinae" = {
      pkg = "vicinae";
      unstable = true;
    };
    "imagemagick" = {
      pkg = "imagemagick";
      bin = "magick";
    };
    "translate-shell" = {
      pkg = "translate-shell";
      bin = "trans";
    };
    "inotifywait" = {
      pkg = "inotify-tools";
    };
    "imv" = {
      pkg = "imv";
      bin = "imv-wayland";
    };
  };

  resolveTag =
    tag:
    let
      override = binPkg.${tag} or null;
      pkgName = if override != null then override.pkg or tag else tag;
      binName = if override != null then override.bin or tag else tag;
      pkg =
        if override != null && builtins.hasAttr "unstable" override && override.unstable then
          pkgs-unstable.${pkgName}
        else
          pkgs.${pkgName};
    in
    getExe' pkg binName;

  extractTags =
    fileContents:
    let
      allContent = builtins.concatStringsSep "\n" fileContents;
      parts = builtins.split "@([a-zA-Z0-9_-]+)@" allContent;
      extractTag = p: if builtins.isList p then builtins.head p else null;
      tags = lib.filter (x: x != null) (map extractTag parts);
    in
    lib.unique tags;
in
{
  inherit extractTags;
  mkSubstitutions =
    {
      files,
      custom ? { },
    }:
    let
      fileContents = map builtins.readFile files;
      tags = map (tag: {
        name = tag;
        value = resolveTag tag;
      }) (extractTags fileContents);
    in
    builtins.listToAttrs tags // custom;
}
