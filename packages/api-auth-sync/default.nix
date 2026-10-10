{
  lib,
  stdenv,
  makeWrapper,
  python3,
  configFile ? null,
  ...
}:

stdenv.mkDerivation {
  pname = "api-auth-sync";
  version = "1.0.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = ./api-auth-sync.py;
  };

  dontBuild = true;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall
    install -Dm0755 api-auth-sync.py $out/bin/api-auth-sync
    wrapProgram $out/bin/api-auth-sync \
      --prefix PATH : ${lib.makeBinPath [ python3 ]} \
      ${lib.optionalString (configFile != null) "--set API_AUTH_CONFIG ${configFile}"}
    runHook postInstall
  '';

  meta = {
    description = "Keeps OpenAI and Anthropic OAuth credentials fresh";
    longDescription = ''
      OAuth refresh tokens rotate and can be single-use. This tool refreshes stale token lineages directly against
      the OpenAI and Anthropic OAuth endpoints (single flight, freshest-wins) and keeps the live auth.json
      files as real regular files (never sops symlinks). Seeds are the sops-nix-deployed
      state-dir JSONs; the dotfiles repo is never touched. Token values are never logged.
    '';
    license = lib.licenses.mit;
    mainProgram = "api-auth-sync";
    platforms = lib.platforms.unix;
  };
}
