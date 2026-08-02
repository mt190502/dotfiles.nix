{ pkgs, rayCli }:

with pkgs;
stdenv.mkDerivation {
  pname = "raycast-extension-easydict";
  version = "0";
  src =
    fetchFromGitHub {
      owner = "raycast";
      repo = "extensions";
      rev = "3b0c72bb82ddef684eeeb9a5d69cb278eecf3efe";
      sha256 = "sha256-f9dBacrE7Wtthk4tWHXiUVviYhznhSA+xilFzNmdnRQ=";
      sparseCheckout = [ "/extensions/easydict" ];
    }
    + "/extensions/easydict";

  nativeBuildInputs = [
    cacert
    nodejs
    yarn
  ];

  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  outputHash = "sha256-joww8YaCuXAg6S8lkDmXgh5J2bYkjE/ynwnFMC57lH0=";
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";

  buildPhase = ''
    export HOME=$TMP
    yarn install --ignore-scripts --no-progress
    rm -rf node_modules/whatlang-node
    cp -r overrides/whatlang-node node_modules/whatlang-node
    sed -i 's/getMacSystemProxy()/Promise.resolve({ HTTPEnable: false, HTTPProxy: undefined, HTTPPort: undefined })/' src/axiosConfig.ts
    mkdir -p node_modules/@raycast/api/bin/linux
    cp ${rayCli} node_modules/@raycast/api/bin/linux/ray
    chmod +x node_modules/@raycast/api/bin/linux/ray
    rm -f node_modules/.bin/ray
    cp ${rayCli} node_modules/.bin/ray
    chmod +x node_modules/.bin/ray
    printf '#!/bin/sh\nexit 0\n' > node_modules/.bin/tsc
    chmod +x node_modules/.bin/tsc
    npm run build
  '';

  installPhase = ''
    mkdir -p $out/
    cp -r /build/.config/*/extensions/easydict/* $out/
  '';
}
