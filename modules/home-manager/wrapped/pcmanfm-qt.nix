{ config, pkgs, ... }:

with pkgs;
rec {
  name = "pcmanfm-qt";
  original = pcmanfm-qt;
  wrap = (
    config.lib.nixGL.wrap (
      pkgs.symlinkJoin {
        name = "${name}-wrapped";
        paths = [ original ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/pcmanfm-qt \
            --set QT_QPA_PLATFORMTHEME qt6ct \
            --set XDG_CURRENT_DESKTOP KDE
        '';
      }
    )
  );
}
