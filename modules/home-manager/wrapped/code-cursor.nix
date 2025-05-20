{ config, pkgs, ... }:

let
  originalPackage = pkgs.code-cursor;
  override = pkgs.symlinkJoin {
    name = "code-cursor-wrapped";
    paths = [ originalPackage ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/cursor \
        --set XDG_CURRENT_DESKTOP GNOME \
        --append-flags "--ozone-platform=wayland --ozone-platform-hint=auto --password-store=gnome"
    '';
    meta.mainProgram = "cursor";
  };
in
{
  name = "code-cursor";
  original = originalPackage;
  wrap =
    if config.wrapped.mode == "nixGL" then
      config.lib.nixGL.wrap override
    else if config.wrapped.mode == "standard" then
      override
    else
      throw "Invalid mode for code-cursor: ${config.wrapped.mode}. Valid modes are: nixGL, standard.";
}
