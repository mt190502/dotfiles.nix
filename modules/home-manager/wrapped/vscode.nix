{ pkgs, pkgs-unstable, ... }:

with pkgs;
symlinkJoin {
  name = "vscode";
  paths = [ pkgs-unstable.vscode ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/code \
      --set XDG_CURRENT_DESKTOP GNOME \
      --append-flags "--ozone-platform=wayland --ozone-platform-hint=auto --password-store=gnome"
  '';
  meta.mainProgram = "code";
}
