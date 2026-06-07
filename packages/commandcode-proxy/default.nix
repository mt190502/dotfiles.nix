{ stdenv, python3, ... }:

stdenv.mkDerivation {
  pname = "commandcode-proxy";
  version = "1.0.0";

  src = ./.;
  dontBuild = true;
  nativeBuildInputs = [ python3 ];
  buildInputs = [ python3 ];

  installPhase = ''
    mkdir -p $out/bin
    cp main.py $out/bin/commandcode-proxy
    chmod +x $out/bin/commandcode-proxy
  '';

  postFixup = ''
    patchShebangs $out/bin/commandcode-proxy
  '';

  meta = {
    description = "A proxy server for CommandCode, written by Kreato.";
    homepage = "https://github.com/kreatoo";
  };
}
