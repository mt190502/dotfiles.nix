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
        rev = "07b26df73f775bc18936944c9b79de5a9c24fe5a";
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
