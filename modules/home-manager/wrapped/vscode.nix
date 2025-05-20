{ config, pkgs, ... }:

let
  originalPackage = pkgs.vscode;
  override = pkgs.symlinkJoin {
    name = "vscode-wrapped";
    paths = [ originalPackage ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/code \
        --set XDG_CURRENT_DESKTOP GNOME \
        --append-flags "--ozone-platform=wayland --ozone-platform-hint=auto --password-store=gnome"
    '';
    meta.mainProgram = "code";
  };
in
{
  name = "vscode";
  original = originalPackage;
  wrap =
    if config.wrapped.mode == "nixGL" then
      config.lib.nixGL.wrap override
    else if config.wrapped.mode == "standard" then
      override
    else
      throw "Invalid mode for vscode: ${config.wrapped.mode}. Valid modes are: nixGL, standard.";
}
