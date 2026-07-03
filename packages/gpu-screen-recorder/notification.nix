#~ forked from https://github.com/rPlakama/gsr-ui-nix. Thanks :)
{ pkgs, ... }:

with pkgs;
stdenv.mkDerivation {
  name = "gpu-screen-recorder-notification";
  version = "1.3.3";
  src = fetchGit {
    url = "https://repo.dec05eba.com/gpu-screen-recorder-notification";
    rev = "fc5da8cb6c0d38f8c60a6045db7fc2dcd69d7bd2";
    ref = "master";
    submodules = true;
  };
  nativeBuildInputs = [
    makeWrapper
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];
  buildInputs = [
    freetype
    glib
    gsettings-desktop-schemas
    libX11
    libXext
    libxkbcommon
    libXrandr
    libXrender
    pango
    wayland
    wayland-scanner
  ];
  preFixup = ''
    wrapProgram $out/bin/gsr-notify \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          addDriverRunpath.driverLink
          libglvnd
        ]
      }
  '';
  meta = {
    description = "Notification overlay for gpu-screen-recorder-ui.";
    homepage = "https://git.dec05eba.com/gpu-screen-recorder-notification/about/";
    license = lib.licenses.gpl3Only;
    mainProgram = "gsr-notify";
    maintainers = [
      {
        email = "enovale@proton.me";
        name = "enova";
      }
      {
        email = "iwisp360@protonmail.com";
        name = "iWisp360";
      }
      {
        email = "rPlakama@proton.me";
        name = "rPlakama";
      }
      {
        email = "mt190502@mtaha.dev";
        name = "Taha";
      }
    ];
    platforms = [ "x86_64-linux" ];
  };
}
