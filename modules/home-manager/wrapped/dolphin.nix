{ config, pkgs, ... }:

with pkgs;
rec {
  name = "dolphin";
  original = kdePackages.dolphin;
  wrap = (
    config.lib.nixGL.wrap (symlinkJoin {
      name = "${name}-wrapped";
      paths = [ original ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/dolphin \
          --set QT_STYLE_OVERRIDE kvantum \
          --set QT_QPA_PLATFORMTHEME qt6ct
      '';
      meta.mainProgram = "dolphin";
    })
  );
}
