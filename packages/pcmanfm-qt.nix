{
  lib,
  symlinkJoin,
  pcmanfm-qt,
  makeWrapper,
  ...
}:

symlinkJoin {
  name = "pcmanfm-qt";
  paths = [ pcmanfm-qt ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/pcmanfm-qt \
      --set QT_QPA_PLATFORMTHEME qt6ct \
      --set XDG_CURRENT_DESKTOP KDE
  '';
  meta = {
    mainProgram = "pcmanfm-qt";
    platforms = lib.platforms.linux;
  };
}
