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
  version = "0.9.1";

  src = fetchurl {
    url = "https://github.com/PrimeIntellect-ai/prime-agent/releases/download/v${version}/prime-agent-${version}.tgz";
    hash = "sha256-RsJNsXgt0xrcNdXGy8x1Vk+rps7TvyzPA9g27ncTRHU=";
  };

  packageLock = fetchurl {
    url = "https://raw.githubusercontent.com/PrimeIntellect-ai/prime-agent/v${version}/package-lock.json";
    hash = "sha256-i+g06iH4HaR7VRj4BkYhEY34afR1412yjPHcYHmtwwg=";
  };

  nativeBuildInputs = [ nodejs_24 ];

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  outputHash = "sha256-SygQUQIPzBOEzhgwkGKZ/cqtppHFXd2vUO3NctLbTIU=";
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
