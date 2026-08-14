#~ forked from https://github.com/rPlakama/gsr-ui-nix. Thanks :)
{
  gpu-screen-recorder-notification ? pkgs.callPackage ./notification.nix { },
  pkgs,
  wrapperDir ? "/run/wrappers/bin",
  ...
}:

with pkgs;
stdenv.mkDerivation {
  name = "gpu-screen-recorder-ui";
  version = "1.12.5";
  src = fetchGit {
    url = "https://repo.dec05eba.com/gpu-screen-recorder-ui";
    rev = "edfc70d99ba9adbce3f7e61642ac21ea1542e50f";
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
    dbus
    desktop-file-utils
    freetype
    glib
    gsettings-desktop-schemas
    libcap
    libdrm
    libpulseaudio
    libX11
    libXcomposite
    libXcursor
    libXext
    libXfixes
    libXi
    libxkbcommon
    libXrandr
    libXrender
    pango
    wayland
    wayland-scanner
  ];
  preFixup =
    let
      gpu-screen-recorder-wrapped = pkgs.gpu-screen-recorder.override {
        inherit wrapperDir;
      };
    in
    ''
      wrapProgram "$out/bin/gsr-ui" \
        --prefix PATH : ${wrapperDir} \
        --suffix PATH : ${
          lib.makeBinPath [
            gpu-screen-recorder-notification
            gpu-screen-recorder-wrapped
            pkgs.bash
          ]
        }:"$out/bin" \
        --prefix LD_LIBRARY_PATH : ${
          lib.makeLibraryPath [
            mesa
            libglvnd
            addDriverRunpath.driverLink
          ]
        }
    '';
  meta = {
    description = "Shadowplay-like frontend for gpu-screen-recorder.";
    homepage = "https://git.dec05eba.com/gpu-screen-recorder-ui/about/";
    license = lib.licenses.gpl3Only;
    mainProgram = "gsr-ui";
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
