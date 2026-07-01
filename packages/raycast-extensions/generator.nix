{
  lib,
  pkgs,
  rayCli,
}:

names:
lib.genAttrs names (
  name:
  with pkgs;
  buildNpmPackage rec {
    inherit name;
    inherit (importNpmLock) npmConfigHook;
    src =
      fetchFromGitHub {
        owner = "raycast";
        repo = "extensions";
        rev = "06006ce095c0bce99b382867229126d6b7e480cc";
        sha256 = "sha256-3AOuysUdLOBS4LnysA9izcq9TfAGjwWfS+ioaQGPX38=";
        sparseCheckout = map (name: "/extensions/${name}") names;
      }
      + "/extensions/${name}";
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
    npmDeps = importNpmLock { npmRoot = src; };
  }
)
