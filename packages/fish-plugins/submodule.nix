{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      legacyPackages.fishPlugins =
        let
          dir = ./.;
          files = lib.filterAttrs (n: _: lib.hasSuffix ".nix" n && n != "submodule.nix") (
            builtins.readDir dir
          );
        in
        lib.mapAttrs' (
          n: _: lib.nameValuePair (lib.removeSuffix ".nix" n) (import "${dir}/${n}" { inherit pkgs; })
        ) files;
    };
}
