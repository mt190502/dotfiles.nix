{
  lib,
  nerd-fonts,
  stdenvNoCC,
  ...
}:

let
  styles = [
    "Bold"
    "BoldItalic"
    "Medium"
    "MediumItalic"
  ];
in
stdenvNoCC.mkDerivation {
  pname = "iosevka-nerd-font";
  inherit (nerd-fonts.iosevka) version src;

  unpackPhase = ''
    runHook preUnpack
    tar -xJf $src --no-same-owner ${lib.concatMapStringsSep " " (s: "IosevkaNerdFont-${s}.ttf") styles}
    runHook postUnpack
  '';
  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share/fonts/truetype/iosevka-nerd-font IosevkaNerdFont-*.ttf
    runHook postInstall
  '';
  meta = {
    description = "Iosevka Nerd Font trimmed to the styles used by Zed";
    homepage = "https://github.com/ryanoasis/nerd-fonts";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
