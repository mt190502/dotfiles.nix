{
  lib,
  stdenv,
  makeWrapper,
  wrapGAppsHook4,
  gobject-introspection,
  python3,
  gtk4,
  libadwaita,
  gtk4-layer-shell,
  translate-shell,
  wl-clipboard,
  xdotool,
  grim,
  slurp,
  tesseract,
  ...
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.pygobject3
    ps.requests
  ]);
  giTypelibPath = lib.makeSearchPath "lib/girepository-1.0" [
    gtk4
    libadwaita
    gtk4-layer-shell
  ];
  runtimePath = lib.makeBinPath [
    translate-shell
    wl-clipboard
    xdotool
    grim
    slurp
    tesseract
  ];
in
stdenv.mkDerivation {
  pname = "lexipop";
  version = "0.1.0";
  src = ./.;
  dontBuild = true;
  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook4
    gobject-introspection
  ];
  buildInputs = [
    pythonEnv
    gtk4
    libadwaita
    gtk4-layer-shell
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin
    cp -r lexipop $out/lib/lexipop
    rm -rf $out/lib/lexipop/__pycache__
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/lexipop \
      --add-flags "-m lexipop" \
      --prefix PYTHONPATH : "$out/lib" \
      --prefix GI_TYPELIB_PATH : "${giTypelibPath}" \
      --prefix PATH : "${runtimePath}" \
      --set GDK_BACKEND wayland
    runHook postInstall
  '';
  meta = {
    description = "System-wide selection-to-Anki capture popup (GTK4/Wayland) using trans and AnkiConnect";
    longDescription = ''
      lexipop watches the primary selection, shows a GTK4 layer-shell popup near
      the pointer with the translation from translate-shell, and saves the card
      to Anki through AnkiConnect. An optional OpenAI-compatible AI button
      produces coloured word alignments.
    '';
    license = lib.licenses.mit;
    mainProgram = "lexipop";
    maintainers = [
      {
        name = "Taha";
        email = "mt190502@mtaha.dev";
      }
    ];
    platforms = lib.platforms.linux;
  };
}
