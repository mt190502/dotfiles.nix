{
  config,
  pkgs,
  ...
}:

(config.lib.nixGL.wrap (
  pkgs.symlinkJoin {
    name = "dolphin";
    paths = [ pkgs.kdePackages.dolphin ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/dolphin \
        --set QT_STYLE_OVERRIDE kvantum \
        --set QT_QPA_PLATFORMTHEME qt6ct 
    '';
    meta.mainProgram = "dolphin";
  }
))
