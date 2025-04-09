{
  config,
  pkgs,
  ...
}:

(config.lib.nixGL.wrap (
  pkgs.symlinkJoin {
    name = "pcmanfm-qt";
    paths = [ pkgs.pcmanfm-qt ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/pcmanfm-qt \
        --set QT_QPA_PLATFORMTHEME qt6ct \
        --set XDG_CURRENT_DESKTOP KDE
    '';
  }
))
