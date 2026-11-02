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
        rev = "bad7de0172ce6ea5e721ed919f4e1d7186f74192";
        sha256 = "sha256-NASCJMjS0ideoSsk/a6iYZfxJY4PhQpRiIXYISczUhY=";
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
      cp -r "$HOME/.config/raycast/extensions/${name}/." "$out/"
      runHook postInstall
    '';
    npmDeps = importNpmLock { npmRoot = extSrc; };
  }
)
