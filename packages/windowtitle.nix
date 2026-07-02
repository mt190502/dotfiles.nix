{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
  name = "WindowTitle";
  src = pkgs.fetchFromGitHub {
    owner = "dhruv8sh";
    repo = "plasma6-window-title-applet";
    rev = "v0.9.0";
    sha256 = "sha256-pFXVySorHq5EpgsBz01vZQ0sLAy2UrF4VADMjyz2YLs=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/plasmoids/org.kde.windowtitle
    cp -r ./* $out/share/plasma/plasmoids/org.kde.windowtitle/
    runHook postInstall
  '';
  passthru.updateScript = pkgs.nix-update-script { };
}
