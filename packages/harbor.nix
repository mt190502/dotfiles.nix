{
  lib,
  stdenv,
  dpkg,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook3,
  # Runtime libraries for autoPatchelfHook
  mpv,
  systemd,
  openssl,
  gtk3,
  gdk-pixbuf,
  cairo,
  glib,
  webkitgtk_4_1,
  libsoup_3,
  libgcc,
  libayatana-appindicator,
  gst_all_1,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "harbor";
  version = "0.9.117";

  src = fetchurl {
    url = "https://github.com/harborstremio-linux/harbor-linux-builds/releases/download/beta-v${finalAttrs.version}/Harbor_${finalAttrs.version}-2_amd64.deb";
    hash = "sha256-cuDsBNrcKaxDQ5GqhQDPpeDz1IojPjaRDSpr4Kaz1+g=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    mpv
    systemd
    openssl
    gtk3
    gdk-pixbuf
    cairo
    glib
    webkitgtk_4_1
    libsoup_3
    libgcc
    libayatana-appindicator
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  #~ libayatana-appindicator is dlopened at runtime; autoPatchelfHook
  #~ won't add it to RUNPATH because it's not in NEEDED.
  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libayatana-appindicator ]}
    )
  '';

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    #~ main binary
    install -Dm755 usr/bin/harbor $out/bin/harbor

    #~ bundled resources (fonts, notices)
    mkdir -p "$out/lib"
    cp -r "usr/lib/Harbor Beta" "$out/lib/Harbor Beta"

    #~ desktop file
    install -Dm644 "usr/share/applications/Harbor Beta.desktop" $out/share/applications/harbor.desktop
    substituteInPlace $out/share/applications/harbor.desktop --replace-fail "Name=Harbor Beta" "Name=Harbor"

    #~ icons
    cp -r usr/share/icons $out/share/
    runHook postInstall
  '';

  meta = {
    description = "A custom Stremio client built for adventure";
    homepage = "https://github.com/harborstremio/harbor";
    license = lib.licenses.mit;
    mainProgram = "harbor";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
