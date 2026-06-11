{ pkgs, ... }:

{
  isDesktopPackage = true;
  package =
    with pkgs;
    symlinkJoin {
      name = "dolphin";
      paths = [ kdePackages.dolphin ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/dolphin \
          --set QT_QPA_PLATFORMTHEME qt6ct \
          --add-flags "-style kvantum-dark"
      '';
      meta.mainProgram = "dolphin";
    };
}
