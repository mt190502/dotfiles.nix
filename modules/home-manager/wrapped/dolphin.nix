{ config, pkgs, ... }:

let
  originalPackage = pkgs.kdePackages.dolphin;
  override = pkgs.symlinkJoin {
    name = "dolphin-wrapped";
    paths = [ originalPackage ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/dolphin \
        --set QT_STYLE_OVERRIDE kvantum \
        --set QT_QPA_PLATFORMTHEME qt6ct
    '';
    meta.mainProgram = "dolphin";
  };
in
{
  name = "dolphin";
  original = originalPackage;
  wrap =
    if config.wrapped.mode == "nixGL" then
      config.lib.nixGL.wrap override
    else if config.wrapped.mode == "standard" then
      override
    else
      throw "Invalid mode for dolphin: ${config.wrapped.mode}. Valid modes are: nixGL, standard.";
}
