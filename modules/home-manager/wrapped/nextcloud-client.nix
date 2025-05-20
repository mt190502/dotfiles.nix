{ config, pkgs, ... }:

let
  originalPackage = pkgs.nextcloud-client;
  override = pkgs.symlinkJoin {
    name = "nextcloud-client-wrapped";
    paths = [ originalPackage ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nextcloud \
        --set QT_STYLE_OVERRIDE kvantum \
        --set QT_QPA_PLATFORMTHEME qt6ct
    '';
    meta.mainProgram = "nextcloud";
  };
in
{
  name = "nextcloud-client";
  original = originalPackage;
  wrap =
    if config.wrapped.mode == "nixGL" then
      config.lib.nixGL.wrap override
    else if config.wrapped.mode == "standard" then
      override
    else
      throw "Invalid mode for nextcloud-client: ${config.wrapped.mode}. Valid modes are: nixGL, standard.";
}
