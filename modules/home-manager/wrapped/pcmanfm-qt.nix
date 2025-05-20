{ config, pkgs, ... }:

let
  originalPackage = pkgs.pcmanfm-qt;
  override = pkgs.symlinkJoin {
    name = "pcmanfm-qt-wrapped";
    paths = [ originalPackage ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/pcmanfm-qt \
        --set QT_QPA_PLATFORMTHEME qt6ct \
        --set XDG_CURRENT_DESKTOP KDE
    '';
    meta.mainProgram = "pcmanfm-qt";
  };
in
{
  name = "pcmanfm-qt";
  original = originalPackage;
  wrap =
    if config.wrapped.mode == "nixGL" then
      config.lib.nixGL.wrap override
    else if config.wrapped.mode == "standard" then
      override
    else
      throw "Invalid mode for pcmanfm-qt: ${config.wrapped.mode}. Valid modes are: nixGL, standard.";
}
