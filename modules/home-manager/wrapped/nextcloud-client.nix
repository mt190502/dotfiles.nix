{
  config,
  pkgs,
  ...
}:

(config.lib.nixGL.wrap (
  pkgs.symlinkJoin {
    name = "nextcloud-client";
    paths = [ pkgs.nextcloud-client ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nextcloud \
        --set QT_STYLE_OVERRIDE kvantum \
        --set QT_QPA_PLATFORMTHEME qt6ct
    '';
  }
))
