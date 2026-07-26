{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  programs = {
    command-not-found.enable = !pkgs.stdenv.isDarwin;
    nix-index = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      package =
        inputs.nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-with-small-db;
    };
  };
}
