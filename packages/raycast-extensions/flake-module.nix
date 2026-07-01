{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      legacyPackages.raycastExtensions =
        let
          rayCli = pkgs.fetchurl {
            url = "https://cli.raycast.com/1.86.0-alpha.65/linux/ray";
            sha256 = "sha256-UgDA2hIH7HwKl3j4UEGIlvh6eE+IWUlSML0wloHFPQw=";
          };
          generator = import ./generator.nix { inherit pkgs lib rayCli; };
          others = lib.mapAttrs' (
            n: _:
            lib.nameValuePair (lib.removeSuffix ".nix" n) (
              pkgs.callPackage "${./others}/${n}" { inherit rayCli; }
            )
          ) (lib.filterAttrs (n: _: lib.hasSuffix ".nix" n && n != ".gitkeep") (builtins.readDir ./others));
        in
        names:
        let
          generatedExts = lib.filter (n: !(others ? ${n})) names;
          otherExts = lib.filter (n: others ? ${n}) names;
        in
        (generator generatedExts) // (lib.getAttrs (lib.unique otherExts) others);
    };
}
