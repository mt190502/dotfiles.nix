{ pkgs, ... }:

with pkgs;
symlinkJoin {
  name = "dolphin";
  paths = [ kdePackages.dolphin ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/dolphin \
      --set QT_STYLE_OVERRIDE kvantum \
      --set QT_QPA_PLATFORMTHEME kde
  '';
  meta.mainProgram = "dolphin";
}
