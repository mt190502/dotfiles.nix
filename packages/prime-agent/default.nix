{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  uv,
  ...
}:

let
  version = "0.10.0";
  sources = {
    x86_64-linux = {
      platform = "linux-x64";
      hash = "sha256-wWvSr153tT9JuRSkR0LEz2pnxe1QAAQUMLeNvUw7y+w=";
    };
    aarch64-linux = {
      platform = "linux-arm64";
      hash = "sha256-88qzUwpNfKQ9vvgyG/E/Jg0boF2LXd4FcWWiC9T2dcQ=";
    };
    x86_64-darwin = {
      platform = "darwin-x64";
      hash = "sha256-r0hmtbqC80GblkKQ4/Aj3bm5mVionhbuhWliuQHsD8Y=";
    };
    aarch64-darwin = {
      platform = "darwin-arm64";
      hash = "sha256-5Bi99i/LAAJ3e/OsQ7zBNlErJnY/KrXFAHkvJuNylOU=";
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
    homepage = "https://app.primeintellect.ai/prime-agent";
    changelog = "https://github.com/PrimeIntellect-ai/prime-agent/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "prime-agent";
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
  };
}
