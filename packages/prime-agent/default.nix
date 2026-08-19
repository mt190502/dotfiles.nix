{
  lib,
  stdenv,
  cacert,
  fetchurl,
  nodejs_24,
  ...
}:

let
  # npm selects different optional dependencies on macOS.
  darwinOutputHash = "sha256-i7ji6CTwtys/4j7dn5ImWyoWba9xSZZRGP8pNlnHpsI=";
in
(stdenv.mkDerivation rec {
  pname = "prime-agent";
  version = "0.7.3";

  src = fetchurl {
    url = "https://github.com/PrimeIntellect-ai/prime-agent/releases/download/v${version}/prime-agent-${version}.tgz";
    hash = "sha256-KhiHODGLkf+R6ne4oLIVxBVDzwSD/LGKU0ddxOcDJ4Q=";
  };

  packageLock = fetchurl {
    url = "https://raw.githubusercontent.com/PrimeIntellect-ai/prime-agent/v${version}/package-lock.json";
    hash = "sha256-wK7B/jSlz+DmAcjvweWwqW1OjXZ3NjP3ZCX08IKapp0=";
  };

  nativeBuildInputs = [ nodejs_24 ];

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  outputHash = "sha256-rDV1h1KEI5HVGGgxv9IlZqIxMC+WpjrFqeVHinYC11M=";
  outputHashMode = "recursive";
  dontPatchShebangs = true;

  buildPhase = ''
    export HOME="$TMPDIR"
    export npm_config_cafile="$SSL_CERT_FILE"
    cp ${packageLock} package-lock.json
    chmod u+w package-lock.json
    npm install --omit=dev --ignore-scripts --no-audit --no-fund
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
}).overrideAttrs
  (
    _:
    lib.optionalAttrs stdenv.hostPlatform.isDarwin {
      outputHash = darwinOutputHash;
    }
  )
