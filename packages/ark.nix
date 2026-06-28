{
  lib,
  symlinkJoin,
  kdePackages,
  makeWrapper,
  ...
}:

symlinkJoin {
  name = "ark";
  paths = [ kdePackages.ark ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/ark \
      --set QT_QPA_PLATFORMTHEME qt6ct \
      --add-flags "-style kvantum-dark"
  '';
  meta = {
    mainProgram = "ark";
    platforms = lib.platforms.linux;
  };
}
