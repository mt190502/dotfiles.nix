{
  cacert,
  curl,
  lib,
  p7zip,
  stdenv,
  ...
}:

let
  ISO = "https://oemsoc.download.prss.microsoft.com/dbazure/X23-81951_26100.1742.240906-0331.ge_release_svc_refresh_CLIENT_ENTERPRISES_OEM_x64FRE_en-us.iso_640de540-87c4-427f-be87-e6d53a3a60b4?t=2c3b664b-b119-4088-9db1-ccff72c6d22e&P1=102816950270&P2=601&P3=2&P4=OC448onxqdmdUsBUApAiE8pj1FZ%2bEPTU3%2bC6Quq29MVwMyyDUtR%2fsbiy7RdVoZOHaZRndvzeOOnIwJZ2x3%2bmP6YK9cjJSP41Lvs0SulF4SVyL5C0DdDmiWqh2QW%2bcDPj2Xp%2bMrI9NOeElSBS5kkOWP8Eiyf2VkkQFM3g5vIk3HJVvu5sWo6pFKpFv4lML%2bHaIiTSuwbPMs5xwEQTfScuTKfigNlUZPdHRMp1B3uKLgIA3r0IbRpZgHYMXEwXQ%2fSLMdDNQthpqQvz1PThVkx7ObD55CXgt0GNSAWRfjdURWb8ywWk1gT7ozAgpP%2fKNm56U5nh33WZSuMZIuO1SBM2vw%3d%3d";
in
stdenv.mkDerivation {
  pname = "msfonts";
  version = "25H2";

  nativeBuildInputs = [
    cacert
    curl
    p7zip
  ];
  CURL_CA_BUNDLE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-bLjJgAxCHjw1F4IdqsK8Hel61s6eiimisJ6VCFjW1RE=";

  dontUnpack = true;
  buildPhase = ''
    curl -L -o /tmp/win.iso '${ISO}'
    mkdir wim fonts
    7z e /tmp/win.iso sources/install.wim -owim
    rm /tmp/win.iso
    7z e wim/install.wim '1/Windows/Fonts/*.ttf' '1/Windows/Fonts/*.ttc' -ofonts
    rm -rf wim
  '';
  installPhase = ''
    mkdir -p $out/share/fonts/truetype/msfonts
    install -Dm644 fonts/*.ttf $out/share/fonts/truetype/msfonts/
    install -Dm644 fonts/*.ttc $out/share/fonts/truetype/msfonts/
  '';
  meta = {
    description = "Microsoft Windows 11 TrueType fonts extracted from installation media";
    license = "unfree";
    platforms = lib.platforms.all;
  };
}
