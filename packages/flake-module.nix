_: {
  perSystem =
    { pkgs, lib, ... }:
    {
      packages = lib.genAttrs (lib.remove "flake-module.nix" (lib.attrNames (builtins.readDir ./.))) (
        p: pkgs.callPackage ./${p} { }
      );
    };
}
