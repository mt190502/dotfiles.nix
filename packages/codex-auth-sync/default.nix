{
  lib,
  stdenv,
  makeWrapper,
  python3,
  sops,
  git,
  openssh,
  configFile ? null,
  ...
}:

stdenv.mkDerivation {
  pname = "codex-auth-sync";
  version = "1.0.0";

  src = ./.;

  dontBuild = true;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall
    install -Dm0755 codex-auth-sync.py $out/bin/codex-auth-sync
    wrapProgram $out/bin/codex-auth-sync \
      --prefix PATH : ${
        lib.makeBinPath [
          python3
          sops
          git
          openssh
        ]
      } \
      ${lib.optionalString (configFile != null) "--set CODEX_AUTH_CONFIG ${configFile}"}
    runHook postInstall
  '';

  meta = {
    description = "Keeps Codex/OpenAI OAuth tokens fresh for opencode and prime-agent, and mirrors them into sops";
    longDescription = ''
      Codex OAuth access tokens live ~10 days and refresh tokens are single-use
      with rotation. This tool refreshes stale token lineages directly against
      auth.openai.com (single flight, freshest-wins), keeps the live auth.json
      files as real regular files (never sops symlinks), and mirrors refreshed
      tokens back into the sops-managed repo. Token values are never logged.
    '';
    license = lib.licenses.mit;
    mainProgram = "codex-auth-sync";
    platforms = lib.platforms.unix;
  };
}
