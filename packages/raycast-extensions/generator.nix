{
  lib,
  pkgs,
  rayCli,
}:

names:
lib.genAttrs names (
  name:
  with pkgs;
  let
    extSrc =
      fetchFromGitHub {
        owner = "raycast";
        repo = "extensions";
        rev = "2d84866d8e964700dbcd77ffa91003b064c527f9";
        sha256 = "sha256-Z5jh4TECkGxKVhgtFHcfaxpVXxCnhjPzAfUgQrzJy6k=";
        sparseCheckout = map (n: "/extensions/${n}") names;
      }
      + "/extensions/${name}";
  in
  buildNpmPackage {
    pname = "raycast-extension-${name}";
    version = "0";
    inherit (importNpmLock) npmConfigHook;
    src = extSrc;
    buildPhase = ''
      runHook preBuild
      mkdir -p node_modules/@raycast/api/bin/linux
      cp ${rayCli} node_modules/@raycast/api/bin/linux/ray
      chmod +x node_modules/@raycast/api/bin/linux/ray
      npm run build
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out/
      cp -r /build/.config/*/extensions/${name}/* $out/
      runHook postInstall
    '';
    npmDeps = importNpmLock { npmRoot = extSrc; };
  }
)
