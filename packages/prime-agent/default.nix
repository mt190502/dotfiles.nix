{
  lib,
  stdenv,
  cacert,
  fetchurl,
  nodejs_24,
  ...
}:

stdenv.mkDerivation rec {
  pname = "prime-agent";
  version = "0.7.2";

  src = fetchurl {
    url = "https://github.com/PrimeIntellect-ai/prime-agent/releases/download/v${version}/prime-agent-${version}.tgz";
    hash = "sha256-vFRx8qYm1ye4ikXrdF//k7EMVUo8T8WRLyXYxkuYf14=";
  };

  nativeBuildInputs = [
    cacert
    nodejs_24
  ];

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  outputHash = "sha256-wzkfrf6EYnegIW13oaEGQac4CS+hy+5VAHtgbn2Mkjs=";
  outputHashMode = "recursive";
  dontPatchShebangs = true;

  buildPhase = ''
    export HOME="$TMPDIR"
    export npm_config_cafile="$SSL_CERT_FILE"
    npm install --omit=dev --ignore-scripts --no-audit --no-fund \
      --fetch-retries=1 --fetch-timeout=60000
  '';

  installPhase = ''
    mkdir -p "$out/bin" "$out/libexec"
    cp -r . "$out/libexec/prime-agent"
    ln -s ../libexec/prime-agent/dist/bundle/cli.js "$out/bin/prime-agent"
  '';

  meta = {
    description = "Coding agent CLI with IPython-backed tools and session management";
    homepage = "https://app.primeintellect.ai/prime-agent";
    changelog = "https://github.com/PrimeIntellect-ai/prime-agent/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "prime-agent";
    platforms = lib.platforms.all;
  };
}
