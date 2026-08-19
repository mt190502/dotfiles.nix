{
  lib,
  appimageTools,
  dwarfs,
  fetchurl,
  libayatana-appindicator,
  runCommand,
  ...
}:

let
  pname = "harbor";
  version = "0.9.117";
  appimage = fetchurl {
    url = "https://github.com/harborstremio-linux/harbor-linux-builds/releases/download/beta-v${version}/Harbor_${version}_amd64.AppImage";
    hash = "sha256-lW8EybyIWTZ1pWtdnzV4DisoHfnjfsO7tjsFCjxJV/g=";
  };
  contents =
    runCommand "${pname}-${version}-extracted"
      {
        nativeBuildInputs = [ dwarfs ];
      }
      ''
        mkdir $out
        dwarfsextract -i ${appimage} -o $out
      '';
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = contents;

  extraPkgs = _: [ libayatana-appindicator ];

  passthru.src = appimage;

  extraInstallCommands = ''
    install -Dm444 ${contents}/Harbor.desktop $out/share/applications/harbor.desktop
    install -Dm444 ${contents}/harbor.png $out/share/icons/hicolor/256x256/apps/harbor.png
  '';

  meta = {
    description = "A custom Stremio client built for adventure";
    homepage = "https://github.com/harborstremio/harbor";
    license = lib.licenses.mit;
    mainProgram = "harbor";
    platforms = [ "x86_64-linux" ];
  };
}
