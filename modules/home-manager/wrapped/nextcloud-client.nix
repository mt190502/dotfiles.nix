{ config, pkgs, ... }:

with pkgs;
rec {
  name = "nextcloud-client";
  original = nextcloud-client;
  wrap = (
    config.lib.nixGL.wrap (symlinkJoin {
      name = "${name}-wrapped";
      paths = [ original ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/nextcloud \
          --set QT_STYLE_OVERRIDE kvantum \
          --set QT_QPA_PLATFORMTHEME qt6ct
      '';
    })
  );
}
