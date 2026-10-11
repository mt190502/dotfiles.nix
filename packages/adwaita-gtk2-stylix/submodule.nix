{
  perSystem =
    { pkgs, ... }:
    {
      legacyPackages.adwaita-gtk2-stylix = base16: pkgs.callPackage ./default.nix { inherit base16; };
    };
}
