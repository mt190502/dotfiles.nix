{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  uv,
  ...
}:

let
  version = "0.9.8";
  sources = {
    x86_64-linux = {
      platform = "linux-x64";
      hash = "sha256-g/sJEpv3jj5gJoISzXCTIWZZGxUYjKpwwbDvvMdiNeI=";
    };
    aarch64-linux = {
      platform = "linux-arm64";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    x86_64-darwin = {
      platform = "darwin-x64";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    aarch64-darwin = {
      platform = "darwin-arm64";
      hash = "sha256-B4yavVGZeO8n9kBDZ+N6KYEmfbR/G5W2CUDqf+bq2Lk=";
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "prime-agent";
  inherit version;

  src = fetchurl {
    url = "https://github.com/PrimeIntellect-ai/prime-agent/releases/download/v${version}/prime-agent-${version}-${
      sources.${stdenvNoCC.hostPlatform.system}.platform
    }.tar.gz";
    hash = sources.${stdenvNoCC.hostPlatform.system}.hash;
  };

  nativeBuildInputs = [ makeWrapper ];

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/prime-agent $out/bin
    cp -r . $out/share/prime-agent
    chmod +x $out/share/prime-agent/prime-agent
    makeWrapper $out/share/prime-agent/prime-agent $out/bin/prime-agent \
      --prefix PATH : ${lib.makeBinPath [ uv ]}
    runHook postInstall
  '';

  meta = {
    description = "Coding agent CLI with IPython-backed tools and session management";
    homepage = "https://github.com/PrimeIntellect-ai/prime-agent";
    changelog = "https://github.com/PrimeIntellect-ai/prime-agent/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "prime-agent";
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
  };
}
