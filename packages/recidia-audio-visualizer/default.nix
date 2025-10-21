{ pkgs, ... }:

with pkgs;
stdenv.mkDerivation rec {
  pname = "recidia-audio-visualizer";
  version = "c7466bd";
  src = fetchFromGitHub {
    owner = "GhostNaN";
    repo = pname;
    rev = version;
    sha256 = "sha256-MM3l0SNV4sWIuxK8OtvU10sBWNDQ5/lwoMkQYT0MSYo=";
  };

  nativeBuildInputs = [
    cmake
    fftw
    glm
    gsl
    libconfig
    meson
    ncurses
    ninja
    pkg-config
    pipewire
    qt6.qtbase
    qt6.wrapQtAppsHook
    shaderc
    vulkan-headers
  ];

  configurePhase = ''
    meson setup build --prefix=$out
  '';

  buildPhase = ''
    ninja -C build
  '';

  installPhase = ''
    ninja -C build install
  '';

  meta = {
    description = "A real-time audio spectrum analyzer";
    homepage = "https://github.com/GhostNaN/recidia";
  };
}
